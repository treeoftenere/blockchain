import React from 'react';
import Navbar from './Navbar.js';
require('../sass/home.scss');
import contract from "truffle-contract";
import Web3 from 'web3';
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
import Q from 'q';

class Home extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      sensors: [
      ],
      selectedSensor: 0,
      detail: '',
    }

    this.getRecord = this.getRecord.bind(this);
    this.setSelectedSensor = this.setSelectedSensor.bind(this)
  }
  setSelectedSensor(index) {
    return () => {
      this.setState({
        selectedSensor: index,
        detail: '',
      });
    }
  }
  //contact the local swarm node and get some data
  getRecord(hash, isManifest) {
    return () => {
      let request

      //the type of request depends on whether or not the passed in hash is for a manifest
      if(isManifest) {
        request = new Request('http://localhost:8500/bzz:/'+hash);
      } else {
        request = new Request('http://localhost:8500/bzzr:/'+hash);
      }
      fetch(request).then(response => {
        return response.text()
      }).then(data => {
        this.setState({detail: data})
      })
    }
  }
  render () {
    let sensors = this.state.sensors.map((sensor, index) => {
      return (
        <div key={sensor.name} onClick={this.setSelectedSensor(index)}>
          <span>{sensor.name}</span>
          <i className="fa fa-chevron-right"  aria-hidden="true"/>
        </div>
      )
    })

    let records = []
    if(this.state.sensors.length > 0) {
      records = this.state.sensors[this.state.selectedSensor].entries.map((record, index) => {
        return (
          <div key={index} onClick={this.getRecord(record.hash, !!record.path)}>
            <span>{record.path || 'Initial Record'}</span>
            <i className="fa fa-chevron-right"  aria-hidden="true"/>
          </div>
        )
      })
    }
    records.reverse()

    return (
      <div id="home">
        <Navbar />

        <main>
          <div id="sensorList">
            <h2>Sensors</h2>
            <div id="sensors">
              {sensors}
            </div>
          </div>
          <div id="dataHistory">
            <h2>Storage History</h2>
            <div id="history">
              {records}
            </div>
          </div>
          <div id="dataDetail">
            <h2>Detail</h2>
            <div id="details">
              {this.state.detail}
            </div>
          </div>
        </main>

      </div>
    );
  }
  componentDidMount() {
    //create an instance of the Tree contract
    var tree_json = require("../../build/contracts/Tree.json");
    var Tree = contract(tree_json);
    Tree.setProvider(new Web3.providers.HttpProvider("http://localhost:8545"));
    Tree.deployed().then(deployed => {
      //get the number of sensors added to the contract
      deployed.getSensorsLength().then(length => {
        let sensorPromises = Array.from(Array(length.toNumber()),(x,i)=>i) //shorthand to create an array [1..length]
        .map(i => deployed.sensors(i))
        return Q.all(sensorPromises);
      }).then(sensors => {
        console.log(sensors);
        return Q.all(
          //using the info for each sensor
          sensors.map(sensorInfo => {
            //return a promise for the sensor's data
            let deferred = Q.defer();

            //parse out the stored hash of the sensor's manifest
            let hash = web3.toAscii(sensorInfo[2]) + web3.toAscii(sensorInfo[3]);
            //create a fetch request
            let request = new Request('http://localhost:8500/bzzr:/'+hash);
            fetch(request).then(response => {
              return response.json()
            })
            .then(data => {
              //convert to Ascii from hex and parse out alphanumeric characters
              data.name = web3.toAscii(sensorInfo[0]).replace(/\W/g, '');
              deferred.resolve(data)
            })
            .catch(e => deferred.reject(e))

            return deferred.promise;
          })
        )
      })
      .then(sensors => {
        console.log(sensors);
        let state = this.state
        this.setState({sensors: sensors})
      })

    })
  }
}

export default Home;
