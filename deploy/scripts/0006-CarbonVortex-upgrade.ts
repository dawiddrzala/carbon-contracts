import { DeployedContracts, InstanceName, setDeploymentMetadata, upgradeProxy } from '../../utils/Deploy';
import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

const func: DeployFunction = async ({ getNamedAccounts }: HardhatRuntimeEnvironment) => {
    const { deployer, tank } = await getNamedAccounts();

    const carbonController = await DeployedContracts.CarbonController.deployed();

    await upgradeProxy({
        name: InstanceName.CarbonVortex,
        from: deployer,
        args: [carbonController.address, tank]
    });

    return true;
};

export default setDeploymentMetadata(__filename, func);
