# blockchain for Tree of Tenere 


To setup and run: 

Download and install golang.  Follow the instructions at:

https://github.com/ethereum/go-ethereum/wiki/Installing-Go#ubuntu-1404 

```
sudo apt-get install -y build-essential golang
```


### Download go-ethereum and build Geth and Swarm

```
git clone https://github.com/ethereum/go-ethereum
cd go-ethereum
make geth
make all
```
The binaries will end up in inside 'build/bin' 

Copy geth and swarm to /usr/local/bin 

```
sudo cp geth /usr/local/bin
sudo cp swarm /usr/local/bin
```

### Download and install nodejs:

```
curl -sL https://deb.nodesource.com/setup_6.x | sudo bash -
sudo apt-get install nodejs 
npm install -g npm 
npm install -g nodemon
```


### Clone this Repository - 

`git clone https://github.com/treeoftenere/blockchain.git` 

Inside the directory:

```
npm install 
npm install -g truffle
```
 

### Start everything

Inside the blockchain-integration folder run 

```
./start.sh
```

This will start a geth node, start geth mining for ether, 
start swarm, and start the node app frontend 

Wait for about 15 minutes for geth to mine some ether, then run 
`truffle deploy --network live` to deploy the smart contracts 

Finally stop and rerun 
```
./start.sh`
```
