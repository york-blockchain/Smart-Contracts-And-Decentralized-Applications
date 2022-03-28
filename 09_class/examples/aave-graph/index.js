const axios = require('axios')

axios.post('https://api.thegraph.com/subgraphs/name/aave/protocol', {
  query: `
  {
    flashLoans(first: 10, orderBy: timestamp, orderDirection: desc) {
      id
      reserve {
        name
        symbol
      }
      amount,
      target,
      timestamp
    }
  }  
  `
})
.then((res) => {
  for (const flashsloan of res.data.data.flashLoans) {
    console.log(flashsloan)
  }
})
.catch((error) => {
  console.error(error)
})