// // export default {
// // 	optimizeDeps: {
// // 		exclude: ['tim-wx-sdk'],
// // 	}
// // };

// import path from 'path';
// import fs from 'fs-extra';
// import { defineConfig } from 'vite';
// import uni from '@dcloudio/vite-plugin-uni';

// // function copyFile(source, destination, package = false) {
// // 	return {
// // 		enforce: 'post',
// // 		async writeBundle() {
// // 			const sourcePath = path.resolve(__dirname, source);
// // 			const miniPath = 'unpackage/dist/dev/mp-weixin';
// // 			let destinationPath = '';
// // 			console.warn('-===========')
// // 			if (package) {
// // 				destinationPath = path.join(__dirname, `${miniPath}/node_modules/`, destination);
// // 			} else {
// // 				destinationPath = path.join(__dirname, miniPath, destination);
// // 			}
// // 			await fs.copySync(sourcePath, destinationPath);
// // 		},
// // 	};
// // }

// function copyFiles() {
// 	return {
// 		enforce: 'post',
// 		async writeBundle() {
// 			await fs.copy(
// 				path.resolve(__dirname, 'images'),
// 				path.join(__dirname, 'unpackage/dist/dev/mp-weixin/images'),
// 			);
// 		},
// 	};
// }

// export default defineConfig({
// 	plugins: [uni(), copyFiles()],
// });
