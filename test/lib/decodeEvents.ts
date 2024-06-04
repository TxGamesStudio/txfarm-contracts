import { BaseContract, ContractReceipt } from "ethers";
import { EventFragment, Result } from "ethers/lib/utils";

function decodeEvents(facets: {[key: string]: [BaseContract]}, res: ContractReceipt) {
    return res.events?.map(e => {
        let contracts = facets[e.address];
        let ef: EventFragment = null!;
        let data: Result = null!;

        for (let c of contracts) {
            try {
                ef = c.interface.getEvent(e.topics[0]);
                data = c.interface.decodeEventLog(ef, e.data, e.topics);  
                break;
            } catch(e) {}
        }
        
        return {
            event: ef.name,
            args: Object.keys(data).reduce((obj: any, k) => {
                if (isNaN(k as any))
                    obj[k] = data[k];
                return obj;
            }, {})
        }
    })
}

exports.decodeEvents = decodeEvents