// npm publish
const fs = require('fs');
const path = require('path');
const os = require('os');
// 因为需要去覆盖 ~/.npmrc 文件, 所以构建环境采用的是 macOS on DevCloud 云主机
let npmToken = '';
const myArgs = process.argv.slice(2);
myArgs.forEach((arg) => {
  if (arg.includes('=')) {
    const [key, value] = arg.split('=');
    if (key === 'npmToken' && value) {
      npmToken = value;
    }
  }
});
if (!npmToken) {
  console.log('not publish npmToken, cant publish npm');
} else {
  fs.writeFileSync(path.resolve(os.homedir(), '.npmrc'), `//registry.npmjs.org/:_authToken=${npmToken}`);
  const content = fs.readFileSync(path.resolve(os.homedir(), '.npmrc'), { encoding: 'utf8' });
  console.log('content: ', content);
}
