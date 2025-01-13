if (process.env.DOCKER === 'true') {
    return;
}

const path = require("path");
const fs = require("fs");
const os = require('os');
const { distPath, createNpgsqlBuildIdConfig, info, error } = require("./rollup.shared.js");

createNpgsqlBuildIdConfig();

if (!fs.existsSync(distPath)) {
    info(`${distPath} → created ...`);
    fs.mkdirSync(distPath);
}

try {
    const testFile = path.join(distPath, '.permission-test');
    fs.writeFileSync(testFile, '');
    fs.unlinkSync(testFile);
    info('Verified write permissions to dist directory');
} catch (err) {
    error('Permission issue detected with dist directory');
    
    const platform = os.platform();

    if (platform === 'win32') {
        info('On Windows, please run your command prompt or PowerShell as Administrator');
    } else if (platform === 'darwin' || platform === 'linux') {
        info('Attempting to fix permissions...');
        Bun.spawnSync(["chmod", "-R", "u+rw", distPath]);
    } else {
        error('Unknown platform. Please ensure you have write permissions to the dist directory');
    }
}
