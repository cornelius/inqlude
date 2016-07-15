**This directory contains a node.js program to update the manifests with topics from 
the file `topics.csv`.** 

Follow the instructions given below to run the program.

* Install node (better to use nvm to install node.js).
* Copy the library folders that contain the manifest files required to be updated 
and paste them at `manifests` directory and `update_manifests` directory. 
* Run `node app.js` from this directory.
* You will find the updated manifests at `update_manifests` directory.


**Note:**
* You should have the `topics.csv` file in the same directory that contains `app.js`.
* Having the manifest files at `manifests` directory is adequate, but make sure that 
you have the same library folder structure at both `manifests` directory and 
`update_manifests` directory.
* Also make sure that you have the details for the required update activity at `topics.csv`.
Each entry at `topics.csv` should have the following format.
<library_name>,<topic1>,<topic2>,<topic3>
