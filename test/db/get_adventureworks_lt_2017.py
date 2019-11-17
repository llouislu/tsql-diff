from urllib.request import urlopen, urlparse


url = 'https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksLT2017.bak'
file = url.split('/')[-1]

response = urlopen(url)
CHUNK = 16 * 1024
with open(file, 'wb') as f:
    while True:
        chunk = response.read(CHUNK)
        if not chunk:
            break
        f.write(chunk)
