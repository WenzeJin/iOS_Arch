"""_summary_
    获取url的html内容,以字符串形式存储html内容
"""

import urllib.request
import re
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

url_head = "https://krazydad.com/inkies/"
result_root = "result/"
EACH_VOLUME_LIMIT = 10

def getHtml(url:str) -> str:
    page = urllib.request.urlopen(url)
    html = page.read().decode('utf-8')
    return html

def storeUrls(urls:list[str], file:str) -> None:
    with open(file, 'w') as f:
        for url in urls:
            f.write(url + '\n')
            
def removeAMP(url:str) -> str:
    """_summary_

    Args:
        url (str): url with &amp; in it

    Returns:
        str: url without &amp; in it
    """
    return url.replace('&amp;', '&')

def replaceSpace(url:str) -> str:
    """_summary_

    Args:
        url (str): url with space in it

    Returns:
        str: url without space in it
    """
    return url.replace(' ', '%20')

def revealPDF(url:str) -> str:
    """_summary_

    Args:
        url (str): krazydad pdf entry page (with ADs)

    Returns:
        str: the real pdf url
    """
    url = url_head + url
    html = getHtml(url)
    url = re.findall(r'(?<=href=\").*pdf(?=\")|(?<=href=\').*pdf(?=\')', html)[0]
    return removeAMP(url)
    

if __name__ == '__main__':
    url = url_head
    print(url)
    html = getHtml(url)
    print('Opening: ' + url)
    urls = re.findall(r'(?<=href=\")index.*?(?=\")|(?<=href=\')index.*?(?=\')', html)
    urls = [removeAMP(url) for url in urls]
    i = 0
    for each in urls:
        html = getHtml(url_head + each)
        print('Opening: ' + url_head + each)
        pdf_urls = re.findall(r'(?<=href=\")index.php\?sv.*(?=\")|(?<=href=\')index.php\?sv.*(?=\')', html)
        pdf_urls = pdf_urls[:min(EACH_VOLUME_LIMIT, len(pdf_urls))]
        pdf_urls = [replaceSpace(removeAMP(url)) for url in pdf_urls]
        print("There are " + str(len(pdf_urls)) + " pdfs in this page: " + each)
        pdf_urls = [revealPDF(url) for url in pdf_urls]
        #continue searching
        storeUrls(pdf_urls, result_root + str(i) + '.txt')
        i += 1
    