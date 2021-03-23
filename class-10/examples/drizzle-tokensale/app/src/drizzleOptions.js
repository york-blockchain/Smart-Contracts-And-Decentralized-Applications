import GBCToken from "./contracts/GBCToken.json";
import TokenSale from "./contracts/TokenSale.json";


const options = {
  contracts: [GBCToken, TokenSale],
  events: {
    GBCToken: ["Transfer","Approval"],
    TokenSale:["Sold"]
  },
  syncAlways:true
};

export default options;
