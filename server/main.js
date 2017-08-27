const execSync = require('child_process').execSync;
const INITIAL_MANIFST = '4f983f498d42445c8c54a7dbe64542e30dd3ac0d9f513b4fafae05e28c852b9b';
const contract = require("truffle-contract");
const Web3 = require('web3');
const osc = require('osc');
const Q = require('q');

exports = module.exports = function (server) {
  const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
  let udpPort = new osc.UDPPort({
    localAddress: "0.0.0.0",
    localPort: 57121,
  });
  udpPort.open();

  //create a reference to the deployed tree contract
  var tree_json = require("../build/contracts/Tree.json");
  var Tree = contract(tree_json);
  Tree.setProvider(new Web3.providers.HttpProvider("http://localhost:8545"));
  Tree.deployed().then(function(deployed) {

    udpPort.on('message', (message) => {
      console.log('received new sensor data', message);
      let sensor = message.address.split('/')[1]
      let date = new Date();

      deployed.isStoredSensor(sensor).then(isStored => {
        let manifestHashPromise = Q.defer();

        if(!isStored) {
          manifestHashPromise.resolve(
            execSync('curl -X POST http://localhost:8500/bzz: -H "Content-Type: text/plain" --data \'Initial Record\'  2> /dev/null').toString()
          )
        } else {
          deployed.getSensorInfo(sensor).then(sensorInfo => {
            console.log(sensorInfo);
            let storedHash = web3.toAscii(sensorInfo[1]).replace(/\W/g, '') + web3.toAscii(sensorInfo[2]).replace(/\W/g, '');
            console.log(storedHash);

            let manifest = execSync('curl http://localhost:8500/bzzr:/'+storedHash+' 2> /dev/null').toString();

            if (manifest.indexOf('404 page not found') !== -1) {
              manifestHashPromise.resolve(
                execSync('curl -X POST http://localhost:8500/bzz: -H "Content-Type: text/plain" --data \'Initial Record\'  2> /dev/null').toString()
              )
            } else {
              manifestHashPromise.resolve(storedHash);
            }
          })
        }

        manifestHashPromise.promise.then(manifestHash => {
          let pathHash = execSync('curl -X POST http://localhost:8500/bzz: -H "Content-Type: text/plain" --data \'' + message.args[0] + '\'  2> /dev/null').toString();

          let newManifestHash = execSync('swarm manifest add ' + manifestHash +
          ' ' + date.toISOString() + ' ' + pathHash).toString();

          let hash1 = newManifestHash.substring(0, 32);
          let hash2 = newManifestHash.substring(32);

          if(isStored) {
            //get a gas estimate for the upload
            deployed.setSensorRecord.estimateGas(sensor, deployed.address, hash1, hash2, {
              from: web3.eth.accounts[0]
            })
            .then( gas => {
              //upload the reference to the swarm file to the Tree contract
              deployed.setSensorRecord(sensor, deployed.address, hash1, hash2, {
                from: web3.eth.accounts[0],
                gas: gas*2,
              });
            })
          } else {
            console.log("add sensor");
            console.log(sensor, deployed.address, 1, hash1, hash2);
            deployed.addSensor.estimateGas(sensor, deployed.address, 1, hash1, hash2, {
              from: web3.eth.accounts[0]
            })
            .then( gas => {
              //upload the reference to the swarm file to the Tree contract
              deployed.addSensor(sensor, deployed.address, 1, hash1, hash2, {
                from: web3.eth.accounts[0],
                gas: gas*2,
              }).then(res => console.log(res));
            })
          }
        })
      })

    })
  });
};
