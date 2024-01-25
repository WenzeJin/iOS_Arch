/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import NaturalLanguage
import CoreML

func getLanguage(text: String) -> NLLanguage? {
    
    let language = NLLanguageRecognizer.dominantLanguage(for: text)
    return language
}

func getPeopleNames(text: String, block: (String) -> Void) {
    let tagger = NLTagger(tagSchemes: [.nameType])
    tagger.string = text
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .joinNames]
    let tags: [NLTag] = [.personalName]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
        if let tag = tag, tags.contains(tag) {
            block("\(text[tokenRange])")
        }
        return true
    }
}

func getSearchTerms(text: String, language: String? = nil, block: (String) -> Void) {
    let tagger = NLTagger(tagSchemes: [.lemma])
    tagger.string = text
    if let language = language {
        tagger.setLanguage(NLLanguage(rawValue: language), range: text.startIndex..<text.endIndex)
    }
    let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation, .omitOther, .joinNames]
    tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
        let token = String(text[tokenRange]).lowercased()
        if let tag = tag {
            let lemma = tag.rawValue.lowercased()
            block(lemma)
            if lemma != token {
                block(token)
            }
        } else {
            block(token)
        }
        return true
    }
}

func analyzeSentiment(text:String) -> Double? {
    let tagger = NLTagger(tagSchemes: [.sentimentScore])
    tagger.string = text
    let (tag, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
    guard let sentiment = tag, let score = Double(sentiment.rawValue) else {return nil}
    return score
}

func getSentimentClassifier() -> NLModel? {
    let model = try! NLModel(mlModel: PosNegClassifier().model)
    model.configuration.setValue(NLLanguage.english, forKey: "language")
    return model
}

func predictSentiment(text: String, sentimentClassifier: NLModel) -> String? {
    return sentimentClassifier.predictedLabel(for: text)
}

 // ------------------------------------------------------------------
// -------  Everything below here is for translation chapters -------
// ------------------------------------------------------------------

func getSentences(text: String) -> [String] {
    let tokenizer = NLTokenizer(unit: .sentence)
    tokenizer.string = text
    let esSentences = tokenizer.tokens(for: text.startIndex..<text.endIndex).map{text[$0]}
    let sentences = esSentences.map{ String($0) }
    return sentences
}

func spanishToEnglish(text: String) -> String? {
    do {
        //Load json map
        let esCharToInt = loadCharToIntJsonMap(from: "esCharToInt")
        let intToEnChar = loadIntToCharJsonMap(from: "intToEnChar")
        
        //generate encoder input
        let vocabSize = esCharToInt.count
        let cleanedText = text
        let encoderIn = initMultiArray(shape: [1, NSNumber(value: cleanedText.count), NSNumber(value: vocabSize)])
        for (i, c) in cleanedText.enumerated() {
          encoderIn[i * vocabSize + esCharToInt[c]!] = 1
        }
        let finEncoderIn = Es2EnCharEncoderInput(encodedSeq: encoderIn)
        
        //get encoder output
        let encoder = try Es2EnCharEncoder(configuration: MLModelConfiguration()).model
        let encoderOutput = try encoder.prediction(from: finEncoderIn)
        let encoder_lstm_h_out = encoderOutput.featureValue(for: "encoder_lstm_h_out")?.multiArrayValue
        let encoder_lstm_c_out = encoderOutput.featureValue(for: "encoder_lstm_c_out")?.multiArrayValue
        
        
        //get decoder input
        let decoderIn = initMultiArray(shape: [NSNumber(value: intToEnChar.count)])
        let temp_h_out = initMultiArray(shape: [1, encoder_lstm_h_out!.shape[0], encoder_lstm_h_out!.shape[1]])
        let temp_c_out = initMultiArray(shape: [1, encoder_lstm_c_out!.shape[0], encoder_lstm_c_out!.shape[1]])
        for i in 0..<Int(truncating: encoder_lstm_c_out!.shape[0])*Int(truncating: encoder_lstm_c_out!.shape[1]) {
            temp_c_out[i] = encoder_lstm_c_out![i]
        }
        for i in 0..<Int(truncating: encoder_lstm_h_out!.shape[0])*Int(truncating: encoder_lstm_h_out!.shape[1]) {
            temp_h_out[i] = encoder_lstm_h_out![i]
        }
        let finDecoderIn = Es2EnCharDecoderInput( encodedChar: decoderIn, decoder_lstm_h_in: temp_h_out, decoder_lstm_c_in: temp_c_out)
        
        //get final output
        let decoder = try Es2EnCharDecoder(configuration: MLModelConfiguration())
        var translatedText: [Character] = []
        var doneDecoding = false
        let startTokenIndex = 0
        let stopTokenIndex = 1
        let maxOutSequenceLength = 65525
        var decodedIndex = startTokenIndex
        while !doneDecoding {
            finDecoderIn.encodedChar[decodedIndex] = 1
            let decoderOut = try! decoder.prediction(input: finDecoderIn)
            finDecoderIn.decoder_lstm_h_in = decoderOut.decoder_lstm_h_out
            finDecoderIn.decoder_lstm_c_in = decoderOut.decoder_lstm_c_out
            finDecoderIn.encodedChar[decodedIndex] = 0
            decodedIndex = argmax(array: decoderOut.nextCharProbs)
            if decodedIndex == stopTokenIndex {
                doneDecoding = true
            } else {
                translatedText.append(intToEnChar[decodedIndex]!)
            }
            if translatedText.count >= maxOutSequenceLength {
                doneDecoding = true
            }
        }
        
        return String(translatedText)
    } catch {
        fatalError("something wrong in translate part")
    }
    
    
}
