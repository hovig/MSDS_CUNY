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

app = Flask(__name__)

soql_url_boro = 'https://data.cityofnewyork.us/resource/nwxe-4ae8.json?$select=boroname&$group=boroname'
tree = pd.read_json(soql_url_boro)
boroughs = tree['boroname'].unique()

@app.route("/")
def show_main_page():
    return render_template('main.html')

@app.route("/borough", methods=['POST'])
def return_trees_boro_pd():
    borough = str(request.form['borough'])
    global boroughs
    if borough in boroughs:
        soql_url = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
            '$select=spc_common, tree_id, health, steward' +\
            '&$where=boroname=\'' + borough + '\'').replace(' ', '%20')
        tree_health = pd.read_json(soql_url).groupby('health').agg({'tree_id':'sum'})
        tree_health.reset_index(inplace=True)
        sum_of_trees = tree_health['tree_id'].sum()
        tree_health.rename(columns = {'tree_id':'proportion'}, inplace=True)
        tree_health['proportion'] = tree_health['proportion']/sum_of_trees

        plt.bar(tree_health['health'], tree_health['proportion'], color='blue')
        plt.xlabel('Tree Health')
        plt.ylabel('Proportion')

        img = io.BytesIO()
        plt.savefig(img, format='png')
        img.seek(0)
        plot_data = quote(base64.b64encode(img.read()).decode())
        return render_template('details.html', **locals())
    else:
        return render_template('error.html')


@app.route('/borough/<string:borough>')
def return_trees_boro(borough):
    global boroughs
    if borough in boroughs:
        url_tree = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
                '$select=spc_common, tree_id, health, steward' +\
                '&$where=boroname=\'' + borough + '\'').replace(' ', '%20')

        url = urlopen(url_tree)
        data = json.loads(url.read().decode())
        return jsonify({'Trees': data})
    else:
        return render_template('error.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
