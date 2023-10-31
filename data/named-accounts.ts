import { DeploymentNetwork } from '../utils/Constants';

const mainnet = (address: string) => ({
    [DeploymentNetwork.Mainnet]: address,
});

const rinkeby = (address: string) => ({
    [DeploymentNetwork.Rinkeby]: address
});

const fantom = (address: string) => ({
    [DeploymentNetwork.Fantom]: address,
});

const base = (address: string) => ({
    [DeploymentNetwork.Base]: address,
    [DeploymentNetwork.Tenderly]: address
});

const canto = (address: string) => ({
    [DeploymentNetwork.Canto]: address,
});

const arbitrum = (address: string) => ({
    [DeploymentNetwork.Arbitrum]: address,
});

const mantle = (address: string) => ({
    [DeploymentNetwork.Mantle]: address,
});

const TestNamedAccounts = {
    ethWhale: {
        ...mainnet('0xDA9dfA130Df4dE4673b89022EE50ff26f6EA73Cf')
    },
    daiWhale: {
        ...mainnet('0x1B7BAa734C00298b9429b518D621753Bb0f6efF2')
    },
    usdcWhale: {
        ...mainnet('0x55FE002aefF02F77364de339a1292923A15844B8')
    },
    wbtcWhale: {
        ...mainnet('0x7f62f9592b823331E012D3c5DdF2A7714CfB9de2')
    },
    bntWhale: {
        ...mainnet('0x221A0e3C9AcEa6B3f1CC9DfC7063509c89bE7BC3')
    }
};

const TokenNamedAccounts = {
    dai: {
        ...mainnet('0x6B175474E89094C44Da98b954EedeAC495271d0F')
    },
    weth: {
        ...mainnet('0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2')
    },
    usdc: {
        ...mainnet('0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48')
    },
    wbtc: {
        ...mainnet('0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599')
    },
    bnt: {
        ...mainnet('0x1F573D6Fb3F13d689FF844B4cE37794d79a7FF1C')
    }
};

export const NamedAccounts = {
    deployer: {
        ...mainnet('ledger://0x5bEBA4D3533a963Dedb270a95ae5f7752fA0Fe22'),
        ...rinkeby('ledger://0x0f28D58c00F9373C00811E9576eE803B4eF98abe'),
        // TODO: fill in before deployment
        ...base('0xe0F7921414e79fE4459148d2e38fb68C9186DECC'),
        ...fantom('0xc9c8449259566cdC82f396FeF5E6EA4b5015708A'),
        ...canto('0x9a1f2Ca05af3A76E111558d670fD3d877456e1Ce'),
        ...arbitrum('0x1ef4046Ca64BBDC05141322645C671a640432Be0'),
        ...mantle('0x6E0AFB1912d4Cc8edD87E2672bA32952c6BB85C3')
    },
    daoMultisig: {
        ...mainnet('0x7e3692a6d8c34a762079fa9057aed87be7e67cb8'),
        ...base('0x15ecCFd11566C71E3d305560d1D8b52859160762'),
        ...canto('0x45ba3e9DC6F167bb60Ab3FAd4f3e3B653e868DC7'),
        ...fantom('0x0bfaEc79F6CEbd39c582e2605C4D96F0Cb4e7D9A'),
        ...arbitrum('0xfee0BAC505E48140A206aB396599BBd6102c2e5C'),
        ...mantle('0xC5B7af905D3ad69EAbD363500E421A568BDBB3A0')
    },
    tank: {
        // TODO: fill in before deployment
        ...base('0x15ecCFd11566C71E3d305560d1D8b52859160762'),
        ...fantom('0x0bfaEc79F6CEbd39c582e2605C4D96F0Cb4e7D9A'),
        ...canto('0x45ba3e9DC6F167bb60Ab3FAd4f3e3B653e868DC7'),
        ...arbitrum('0xfee0BAC505E48140A206aB396599BBd6102c2e5C'),
        ...mantle('0xC5B7af905D3ad69EAbD363500E421A568BDBB3A0')
    },

    ...TokenNamedAccounts,
    ...TestNamedAccounts
};
