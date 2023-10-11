import { DeployedContracts, deployProxy, grantRole, InstanceName, setDeploymentMetadata } from '../../utils/Deploy';
import { Roles } from '../../utils/Roles';
import { DeployFunction } from 'hardhat-deploy/types';
import { HardhatRuntimeEnvironment } from 'hardhat/types';

const func: DeployFunction = async ({ getNamedAccounts }: HardhatRuntimeEnvironment) => {
    const { deployer, tank } = await getNamedAccounts();
    const carbonController = await DeployedContracts.CarbonController.deployed();

    await deployProxy({
        name: InstanceName.CarbonVortex,
        from: deployer,
        args: [carbonController.address, tank]
    });

    const carbonVortex = await DeployedContracts.CarbonVortex.deployed();

    await grantRole({
        name: InstanceName.CarbonController,
        id: Roles.CarbonController.ROLE_FEES_MANAGER,
        member: carbonVortex.address,
        from: deployer
    });

    await carbonVortex.setTank(tank);

    return true;
};

export default setDeploymentMetadata(__filename, func);
