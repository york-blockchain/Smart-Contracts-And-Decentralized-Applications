import YorkToken from "./contracts/YorkToken.json";

const options = {
    contracts: [YorkToken],
    events : {
        YorkToken:["Transfer","Approval"]
    },
    alwaysSync:true
}
export default options;