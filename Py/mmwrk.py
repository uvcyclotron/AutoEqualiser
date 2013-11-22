import sqlite3 as lite
import sys
import csv

con = None #init with none value

# define IUNICODE collation function
def iUnicodeCollate(s1, s2):
    return cmp(s1.lower(), s2.lower())

	
try:
	con=lite.connect('MM.DB') 		#establish connection to db, and returns connection object
	cur=con.cursor() 			#cursor obj traverses the records
	
		
	# register our custom IUNICODE collation function
	con.create_collation('IUNICODE', iUnicodeCollate)
	# run your query, business as usual


	#get SQL version
	#cur.execute('SELECT SQLITE_VERSION()')
	#data=cur.fetchone()  	#fetch one record of data
	#print "SQLite version: %s" % data 
	
	
	#table:Songs, columns: SongTitle, Genre, SongPath ; others: Artist,Album
	#get data and print:
	cur.execute("SELECT Artist,SongTitle,Genre FROM Songs")
	tabs=cur.fetchall()
	
	
	#store db fetched values to songlist file
	file=open("songlist.txt","w")
	for tab in tabs:
		print tab[0],"\t",tab[1],"\t",tab[2] #print db values
		txt=str(tab[0])+";"+str(tab[1])+";"+str(tab[2])+"\n" 	#generate semicolon separated text and writet to file
		file.write(txt)
	file.close()
	
	
	#now read matlab output text and update genres
	file=open("songlistnew.txt","r")
	rows=file.readlines() 	#get each line in rows as a list
	for rwd in rows:
		rwd= rwd.strip().split(';') #split each line using ; as a delim, and strip ending newline, and make rw an array of the output parts
		
	#rwd format: 		ARTIST | SONG TITLE | GENRE		
	#getting collate error
	cur.execute("UPDATE Songs SET Genre=? WHERE SongTitle=?",(str(rwd[2]),str(rwd[1])))
	p=cur.commit() #to commit the update changes to db
	#print p
	file.close()
			
	
except lite.Error, e:
	print "Error %s" % e.args[0]
	sys.exit(1)
finally:
	if con:
		con.close()


	