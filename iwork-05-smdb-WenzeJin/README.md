# iwork-05 SMDB影评 

## 要求

iOS assignment 5: SMDB影评app之功能完善

基于提供的xcode工程SMDB以及情感分析(Sentiment Analysis)和机器翻译模型，利用Netural Language Framework、CoreML和CreateML.app完成：

功能需求：

1. 按语种划分电影评论
2. 按演员(actor)划分电影评论
3. 完善App内置的搜索功能
4. 情感分析（positive or negative）
5. 完善SMDB内NLPHelper.swift中的getSentences和spanishToEnglish方法，实现App中的翻译功能

非功能需求：

阅读代码，根据数据集分布设置你觉得合适的档位，用以划分情感分析模型的预测数值

情感分析数据集地址: https://box.nju.edu.cn/f/b426ccecaf594d9ab1bc/?dl=1

## 展示视频链接

[展示视频](https://www.bilibili.com/video/BV1rV41197EY/)

## 项目简介

首先，语言识别、人名、搜索功能的一些实现只需要简单实用NaturalLanguage库的API即可实现。

```swift

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

```

关于搜索的部分，我发现如果实用SMDB本来提供的方法，会出现一些问题，比如我想要搜索“A B”，结果中只要包含“A” 和 “B” 的其中一个就可以了，同时，由于输入“B”之后刷新了搜索结果，而且刷新的顺序是根据review的先后顺序决定的，有可能只包含“B”的评论因为顺位靠前而被展示到了前面，而真正同时包含“A” 和 “B”的评论则被排到了后面展示，这显然是不合理的，所以我对`ReviewsTableViewController.swift`中的`findMatches`方法做了一些改动。

```swift
func findMatches(_ searchText: String) {
    var matches: Set<Review> = []
    var matchesHits: [Review: Int] = [:]
    var searchTerms: [String] = []
    var searchTermsCount: Int;
    let searchConfidence = 0.7  // 70% of search terms must match
    getSearchTerms(text: searchText, language: Locale.current.languageCode) { term in
        searchTerms.append(term)
    }
    for term in searchTerms {
        guard let reviewsForTerm = ReviewsManager.instance.searchTerms[term] else {
            continue
        }
        for review in reviewsForTerm {
            matchesHits[review] = (matchesHits[review] ?? 0) + 1
        }
    }
    searchTermsCount = searchTerms.count
        let result = matchesHits.sorted { (str1, str2) -> Bool in
        return str1.1 > str2.1
    }
    for (review, hits) in matchesHits {
        if Double(hits) / Double(searchTermsCount) > searchConfidence {
            matches.insert(review)
        }
    }
    reviews = matches.filter { baseReviews.contains($0) }

    /* old version
    var matches: Set<Review> = []
    getSearchTerms(text: searchText, language: Locale.current.languageCode) { term in
        if let founds = ReviewsManager.instance.searchTerms[term] {
        matches.formUnion(founds)
        }
    }
    reviews = matches.filter { baseReviews.contains($0) }
    */
}
```

之后是自己训练二分类模型的部分，代码如下

```swift
func getSentimentClassifier() -> NLModel? {
    let model = try! NLModel(mlModel: PosNegClassifier().model)
    model.configuration.setValue(NLLanguage.english, forKey: "language")
    return model
}

func predictSentiment(text: String, sentimentClassifier: NLModel) -> String? {
    return sentimentClassifier.predictedLabel(for: text)
}
```

最后的翻译部分，由于模拟器存在bug，无法正确演示功能，以下是我的实现

```swift
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

```
