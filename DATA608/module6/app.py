import io
import json
from flask import Flask, jsonify, render_template, request
try:
	from urllib.request import urlopen,quote
except ImportError:
	from urllib2 import urlopen,quote
import pandas as pd
import matplotlib
matplotlib.use('agg')
import matplotlib.pyplot as plt
import base64
import requests

app = Flask(__name__)

url = 'https://raw.githubusercontent.com/hovig/MSDS_CUNY/master/data/presidents.csv'
df = pd.read_csv(url,index_col=0,parse_dates=[0])


@app.route("/")
def show_main_page():
    return render_template('main.html')


@app.route('/borough/<string:borough>')
def return_trees_boro(borough):
	data = requests.get('http://tree-grateful-raven.mybluemix.net/borough/'+borough).content
	tree_health = pd.read_json(data)

	return render_template('details.html', **locals())

@app.route('/multiples/<string:num>')
def return_multiples(num):
	print('Type of num is :', type(num))
	row = [int(num)]
	for i in range(int(num),int(num)+20):
		row.append(int(num)*i)

	table = "<table class = 'table table-bordered'>";
	table += ("<tr><td>" + str(row[0]) + "</td><td>" + str(row[1]) + "</td><td>" + str(row[2]) + "</td><td>" + str(row[3]) + "</td></tr>")
	table += ("<tr><td>" + str(row[4]) + "</td><td>" + str(row[5]) + "</td><td>" + str(row[6]) + "</td><td>" + str(row[7]) + "</td></tr>")
	table += ("<tr><td>" + str(row[8]) + "</td><td>" + str(row[9]) + "</td><td>" + str(row[10]) + "</td><td>" + str(row[11]) + "</td></tr>")
	table += ("<tr><td>" + str(row[12]) + "</td><td>" + str(row[13]) + "</td><td>" + str(row[14]) + "</td><td>" + str(row[15]) + "</td></tr>")
	table += ("<tr><td>" + str(row[16]) + "</td><td>" + str(row[17]) + "</td><td>" + str(row[18]) + "</td><td>" + str(row[19]) + "</td></tr>")
	table += "</table>"

	return render_template('multiples.html', **locals())


@app.route('/word/<string:word>')
def return_reversed_word(word):
	reversed = word[-1::-1]

	return render_template('words.html', **locals())

@app.route("/list", methods=['GET'])
def return_list():
	data = df.to_html()

	return render_template('listings.html', **locals())

@app.route('/name/<string:name>')
def return_preidentsDetails(name):
	names = []
	for index, rows in df.iterrows():
		names.append(index)
	df['id'] = [x for x in names]
	df.set_index(df['id'], inplace=True)
	d=df[['Height', 'Weight']]
	data = d.loc[df['id']==name.replace(' ', '%20')].to_html()

	return render_template('presidentsDetails.html', **locals())


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
