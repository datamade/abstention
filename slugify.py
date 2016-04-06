from django.utils.text import slugify
import sys
import csv

reader = csv.DictReader(sys.stdin)
writer = csv.DictWriter(sys.stdout, reader.fieldnames + ['url'])
writer.writeheader()

for row in reader :
    row['url'] = 'https://nyc.councilmatic.org/legislation/' + slugify(row['identifier'])
    writer.writerow(row)
                         
    
