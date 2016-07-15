var fs = require('fs');
var recursive = require('recursive-readdir');

var parse = require('csv-parse');
var csvAr;

var parser = parse({delimiter: ','}, function(err, data){
    csvAr = data;
});

fs.createReadStream(__dirname+'/topics.csv').pipe(parser);

recursive('manifests', function (err, files) {
  for (var i = files.length - 1; i >= 0; i--) {
    var fi = files[i];
    var data = fs.readFileSync(fi, 'utf8');
    var manifest = JSON.parse(data);
    var name = manifest.name;
    var sel = csvAr.filter(function(d) {
         return d[0] == name;
    })[0];

    if(!sel){
      console.log(fi);
    }
    var sel1 = sel;
    
    sel1 = sel.slice(1);
    for (var j = 0; j < sel1.length ; j++) {
       if(sel1[j] === ''){
         sel1 = sel1.slice(0,j);
         break;
       }
    }
    
    manifest.topics = sel1;
    var data1 = JSON.stringify(manifest, null, 2) + '\n';
    
    var fi2 = 'update_'+ fi;
    fs.writeFileSync(fi2, data1);
  }
});

