import dash
import json
import pandas as pd
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output
import plotly.graph_objs as go

app = dash.Dash()
server = app.server

soql_url_tree = 'https://data.cityofnewyork.us/resource/nwxe-4ae8.json?$select=spc_common&$group=spc_common'
tree = pd.read_json(soql_url_tree)
species = tree['spc_common'].unique()

soql_url_boro = 'https://data.cityofnewyork.us/resource/nwxe-4ae8.json?$select=boroname&$group=boroname'
tree = pd.read_json(soql_url_boro)
boro = tree['boroname'].unique()

options = {
    'color': '#00000',
    'position': 'center'
}

def return_trees(tree_input, boro_input):
    boro = boro_input
    tree_select = tree_input
    soql_url = ('https://data.cityofnewyork.us/resource/nwxe-4ae8.json?' +\
            '$select=spc_common, tree_id, health, steward' +\
            '&$where=boroname=\'' + boro + '\' AND ' +\
            'spc_common=\'' + tree_select + '\'').replace(' ', '%20')
    soql_trees = pd.read_json(soql_url)
    return(soql_trees)

markdown_file = '''
**[Click here for the dataset source](https://data.cityofnewyork.us/Environment/2015-Street-Tree-Census-Tree-Data/uvpi-gqnh).**
'''

app.layout = html.Div([
            html.H1(children="CUNY 608 Module 4 - New York City Tree Census",
                    style={
                        'textAlign':options['position'],
                        'color':options['color'],
                        'text-decoration': 'underline'
                    }),
            html.Label('Select from tree species:'),
            dcc.Dropdown(id='treeSpecies',
                        options=[{'label':i,'value':i} for i in species],
                        value='American beech',
                        style={'marginBottom': 40, 'width':300}),

            html.Label('Select from boroughs:'),
            dcc.Dropdown(id='Boro',
                        options=[{'label':i,'value':i} for i in boro],
                        value='Manhattan',
                        style={'marginBottom': 40, 'width':300}),
            html.Div([
                html.Div([
                    html.Div(id='info-out'),
                    html.Div([dcc.Graph(id='tree_health')]),
                    html.Div([dcc.Graph(id='steward_health')]),
                    html.Div([dcc.Graph(id='steward_health_2')])
                ])
            ], style={'paddingTop':35}),
            dcc.Markdown(markdown_file)
    ])

@app.callback(Output('tree_health','figure'), [Input('treeSpecies', 'value'), Input('Boro', 'value')])
def show_health(tree_input, boro_input):
    tree_health = return_trees(tree_input, boro_input)
    tree_health = tree_health.groupby('health').agg({'tree_id':'sum'})
    tree_health.reset_index(inplace=True)
    sum_of_trees = tree_health['tree_id'].sum()
    tree_health.rename(columns = {'tree_id':'proportion'}, inplace=True)
    tree_health['proportion'] = tree_health['proportion']/sum_of_trees
    trace = [{'x':tree_health['health'], 'y':tree_health['proportion'],'type':'bar'}]
    layout = go.Layout(title='Health of the Trees by Proportion',
                        xaxis = {'title':'Health'},
                        yaxis = {'title': 'Proportion'},
                        hovermode = 'closest')
    return({'data': trace, 'layout': layout})

@app.callback(Output('steward_health','figure'), [Input('treeSpecies', 'value'), Input('Boro', 'value')])
def show_health(tree_input, boro_input):
    tree_health = return_trees(tree_input, boro_input)
    tree_health = tree_health.groupby('steward').agg({'tree_id':'sum'})
    tree_health.reset_index(inplace=True)
    tree_health.rename(columns = {'tree_id':'count'}, inplace=True)
    trace = [{'x':tree_health['steward'], 'y':tree_health['count'],'type':'bar'}]
    layout = go.Layout(title='How many stewards for {} in {}?'.format(tree_input.upper(), boro_input.upper()),
                        hovermode = 'closest')
    return({'data':trace, 'layout':layout})

@app.callback(Output('steward_health_2','figure'), [Input('treeSpecies', 'value'), Input('Boro', 'value')])
def show_health(tree_input, boro_input):
    tree_health = return_trees(tree_input, boro_input)
    tree_health = tree_health.groupby(['health','steward']).agg({'tree_id':'sum'})
    steward_pct = tree_health.groupby(level=0).apply(lambda x: 100 * x / float(x.sum()))
    steward_pct.rename(columns = {'tree_id':'percentage'}, inplace=True)

    health = []
    steward = []
    traces = []

    for level in steward_pct.index.get_level_values('health'):
        if level not in health:
            health.append(level)

    for level in steward_pct.index.get_level_values('steward'):
        if level not in steward:
            steward.append(level)

    steward_pct.reset_index(inplace=True)

    for level in steward:
        df = steward_pct[steward_pct['steward'] == level]
        trace = go.Bar(
            x = df['health'],
            y = df['percentage'],
            name = level
        )
        traces.append(trace)

    layout = go.Layout(title = "Percentage of 'Number of Stewards' by Health of {}".format(tree_input.upper()),
                    yaxis = {'title':'Percentage'})
    return({'data': traces, 'layout': layout})

if __name__ == '__main__':
    app.run_server(debug=True, host='0.0.0.0', port=8080)
