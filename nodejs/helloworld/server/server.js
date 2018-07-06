const express = require('express')
var fs = require('fs');
var parseArgs = require('minimist');
var path = require('path');
var _ = require('lodash');
var grpc = require('grpc');

const app = express()

app.get('/', (req, res) => res.send('DEMO '))

app.listen(8080, () => console.log('Example app listening on port 8080!'))


