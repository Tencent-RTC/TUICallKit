/**
 * 这是同步脚本，用来从vue3版本同步到vue2版本，能够监听文件和文件夹的删除，修改，新增，移动
 * targetProjectName vue2版本的项目名称
 * sourceProjectName vue3版本的项目名称
 * WatchPath 监控的路径，目前是vue3版本的src路径
 * ignoredList 忽略变动的路径列表
 */
const chokidar = require("chokidar");
const path = require("path");
const fs = require("fs");

const targetProjectName = "call-engine-demo-vue2";
const sourceProjectName = "call-engine-demo-vue3";
const WatchPath = path.resolve(__dirname, `../../${sourceProjectName}/src`);
const ignoredList = [
  `../../${sourceProjectName}/src/router/index.ts`,
  `../../${sourceProjectName}/src/main.ts`,
  `../../${sourceProjectName}/src/App.vue`,
  `../../${sourceProjectName}/src/components/compatibleComponents/`,
];

// 相对路径转绝对路径
function relave2absolute(relatePath) {
  return path.resolve(__dirname, relatePath);
}

const watcher = chokidar.watch(WatchPath, {
  ignoreInitial: true,
  ignored: ignoredList.map(relave2absolute),
});

function onAdd(modifyFilePath) {
  console.log("add", modifyFilePath);
  const targetFilePath = modifyFilePath.replace(
    sourceProjectName,
    targetProjectName
  );
  fs.copyFileSync(modifyFilePath, targetFilePath);
}
function onAddDir(modifyFilePath) {
  console.log("onAddDir", modifyFilePath);
  const targetFilePath = modifyFilePath.replace(
    sourceProjectName,
    targetProjectName
  );
  fs.cpSync(modifyFilePath, targetFilePath, { recursive: true });
}
function onChange(modifyFilePath) {
  console.log("onChange", modifyFilePath);

  const targetFilePath = modifyFilePath.replace(
    sourceProjectName,
    targetProjectName
  );
  if (fs.existsSync(targetFilePath)) {
    fs.unlinkSync(targetFilePath);
  }
  fs.copyFileSync(modifyFilePath, targetFilePath);
}
function onUnlink(modifyFilePath) {
  console.log("onUnlink", modifyFilePath);

  const targetFilePath = modifyFilePath.replace(
    sourceProjectName,
    targetProjectName
  );
  if (fs.existsSync(targetFilePath)) {
    fs.unlinkSync(targetFilePath);
  }
}
function onUnlinkDir(modifyFilePath) {
  const targetFilePath = modifyFilePath.replace(
    sourceProjectName,
    targetProjectName
  );
  if (fs.existsSync(targetFilePath)) {
    fs.rmdirSync(targetFilePath, { recursive: true });
  }
}

// 文件事件监听
watcher.on("add", onAdd).on("change", onChange).on("unlink", onUnlink);

// 文件夹事件监听
watcher.on("addDir", onAddDir).on("unlinkDir", onUnlinkDir);
