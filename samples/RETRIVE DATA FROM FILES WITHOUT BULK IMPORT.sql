


SELECT * FROM
OPENROWSET(
	BULK 'D:\Scripts\sample.csv',
	FORMATFILE = 'D:\Scripts\sampleformat.fmt',
	FIRSTROW=2,
    FORMAT='CSV'
) AS D

--Site: https://coderscay.blogspot.com/2017/11/how-to-generate-format-file-for-bulk.html

