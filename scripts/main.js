const yargs = require('yargs/yargs')
const { hideBin } = require('yargs/helpers')
const { alias } = require('yargs')

if (require.main === module) {
    const argv = yargs(hideBin(process.argv))
        .command("deploy", "Deploy all contracts", (yargs) => {},
        (argv) => {
            process.env.HARDHAT_NETWORK = argv.network
            
            const { deploy } = require('./deploy')
            deploy()
                .catch(error => {
                    console.error(error)
                    process.exit(1)
                })
        })
        .command("upgrade", "Upgrade Diamond", (yargs) => {
            return yargs
                .positional('diamondAddress', {
                    describe: 'Diamond Address',
                    alias: 'a',
                    type: 'string'
                })
                .positional('facetName', {
                    describe: 'Facet to Upgrade',
                    alias: 'f',
                    type: 'string'
                })
                .positional('selectorsToRemove', {
                    describe: 'Selectors to Remove', 
                    alias: 'r',
                    type: 'string',
                })
        }, (argv) => {
            process.env.HARDHAT_NETWORK = argv.network

            let selectorsToRemove = argv.selectorsToRemove ? argv.selectorsToRemove.split(',') : []

            const { upgrade } = require('./upgrade')
            upgrade(argv.diamondAddress, argv.facetName, selectorsToRemove)
        })
        .option('network', {
            type: 'string',
            default: 'local'
        })
        .help()
        .parse()
}