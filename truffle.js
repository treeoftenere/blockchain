module.exports = {
  networks: {
  live: {
    host: "localhost",
    port: 8545,
    network_id: 7631461
  },
  development: {
    host: "localhost",
    port: 8545,
    network_id: "*" // Match any network id
  },
  }
};