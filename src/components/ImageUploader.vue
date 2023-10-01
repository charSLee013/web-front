<template>
  <div
    class="bg-gray-100 min-h-screen flex flex-col items-center justify-center bg-gradient-to-r from-purple-400 via-pink-500 to-red-500">
    <h1 class="text-4xl font-extrabold text-white mb-8">
      <span class="text-purple-400">发现</span><span class="text-pink-400">ACG</span><span class="text-red-400">世界</span>
    </h1>
    <p class="text-lg font-bold text-white mb-8">上传图片，寻找相似灵魂！</p>
    <div class="relative w-96 h-96 border-4 border-dashed border-gray-300 rounded-xl p-4 bg-white shadow-lg">
      <input type="file" id="image-input" class="hidden" accept="image/*" @change="handleImageChange">
      <label for="image-input" class="flex flex-col items-center justify-center h-full cursor-pointer">
        <img v-if="image" :src="image" class="w-full h-full object-cover rounded-lg" alt="Image preview">
        <div v-else class="flex flex-col items-center justify-center text-gray-400">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-16 w-16" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
              d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L22 14M6 8a2 2 0 11-4 0 2 2 0 014 0zm9.5-3a3.5 3.5 0 11-7 0 3.5 3.5 0 017 0z" />
          </svg>
          <p class="text-lg font-medium">Click or drag image here</p>
        </div>
      </label>
    </div>
    <button :disabled="!image || uploading" @click="handleImageUpload"
      class="mt-10 w-40 h-12 bg-white text-purple-600 font-bold rounded-full shadow-md transition duration-300 ease-in-out transform hover:scale-110 hover:shadow-xl focus:outline-none focus:ring focus:ring-purple-300 focus:ring-opacity-50">
      <span v-if="!uploading">Upload</span>
      <span v-if="uploading">Uploading...</span>
    </button>
    <div v-if="uploading || result || error" class="mt-5 w-full max-w-sm h-4 bg-gray-200 rounded-full overflow-hidden">
      <div :class="[uploading ? 'bg-purple-600' : (result ? 'bg-green-600' : 'bg-red-600')]"
        :style="{ width: progress + '%' }" class="h-full transition-all duration-[1s] ease-linear"></div>
    </div>
    <div v-if="result" class="mt-10 grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-6">
      <div class="bg-white rounded-lg shadow-lg p-4" v-for="(item, index) in result" :key="index">
        <a :href="'https://www.pixiv.net/artworks/' + item.illust_id" target="_blank">
          <img :src="item.thumb_url" alt="thumb" class="w-full h-48 object-cover rounded-lg mb-4">
        </a>
        <p class="text-lg font-medium text-gray-800">{{ item.title }}</p>
        <div class="flex items-center mt-2">
          <img :src="item.profile_img" alt="profile" class="w-8 h-8 rounded-full mr-2">
          <span class="text-gray-800">{{ item.user_name }}</span>
        </div>
      </div>
    </div>
    <p v-if="error" class="mt-5 text-xl font-medium text-white">{{ error }}</p>
  </div>
</template>

<script>
import CryptoJS from 'crypto-js'

export default {
  data() {
    return {
      image: null, // 用来存储用户选择的图片的数据，这里是一个 base64 编码的字符串
      uploading: false, // 用来表示图片是否正在上传的状态，这里是一个布尔值
      progress: 0, // 用来表示图片上传的进度百分比，这里是一个数字
      result: null, // 用来存储图片上传后返回的推荐内容，这里是一个数组或者 null
      error: null, // 用来存储图片上传过程中出现的错误信息，这里是一个字符串或者 null
    };
  },
  methods: {
    handleImageChange(e) {
      // 当用户选择了图片时，获取图片的数据，并显示在页面上
      const file = e.target.files[0]; // 获取用户选择的文件对象，这里只取第一个文件
      if (file) { // 如果文件对象存在，说明用户选择了图片
        const reader = new FileReader(); // 创建一个 FileReader 对象，用来读取文件数据
        reader.onload = (e) => { // 设置一个回调函数，在读取文件数据完成后执行
          this.image = e.target.result; // 将读取到的文件数据赋值给 this.image，这里是一个 base64 编码的字符串
        };
        reader.readAsDataURL(file); // 使用 reader.readAsDataURL 方法来读取文件数据，将其转换为 base64 编码的字符串
      }
    },
    calculateMD5(blob) {
      // 定义一个函数，用来计算 Blob 数据的 MD5 值，返回一个 Promise 对象
      return new Promise((resolve, reject) => { // 创建一个 Promise 对象，用来表示异步操作的结果
        const reader = new FileReader(); // 创建一个 FileReader 对象，用来读取 Blob 数据
        reader.onload = function () { // 设置一个回调函数，在读取 Blob 数据完成后执行
          const arrayBuffer = this.result; // 获取读取到的 Blob 数据，这里是一个 ArrayBuffer 对象，表示原始的二进制缓冲区
          const wordArray = CryptoJS.lib.WordArray.create(new Uint8Array(arrayBuffer)); // 使用 CryptoJS 库将 ArrayBuffer 数据转换为 WordArray 对象，这里是一个无符号8位整数数组，表示图片数据的字节序列
          const md5 = CryptoJS.MD5(wordArray).toString(); // 使用 CryptoJS 库计算 WordArray 对象的 MD5 值，并转换为字符串格式
          resolve(md5); // 将计算出来的 MD5 值作为 Promise 对象的成功值返回
        };
        reader.onerror = function (error) { // 设置一个回调函数，在读取 Blob 数据过程中出现错误时执行
          reject(error); // 将错误对象作为 Promise 对象的失败值返回
        };
        reader.readAsArrayBuffer(blob); // 使用 reader.readAsArrayBuffer 方法来读取 Blob 数据，返回一个 ArrayBuffer 对象
      });
    },
    handleImageUpload() {
      this.startProgress(); // 进度条开始
      // 当用户点击了上传按钮时，压缩图片为512x512大小，并上传到服务器，同时显示进度条和结果或错误
      this.uploading = true; // 设置上传状态为true，表示开始上传图片
      this.progress = 0; // 初始化进度为0，表示还没有上传任何数据
      this.result = null; // 清空之前的结果，表示还没有获取到推荐内容
      this.error = null; // 清空之前的错误，表示还没有出现任何错误

      const canvas = document.createElement("canvas"); // 创建一个画布元素，用来压缩图片
      canvas.width = 512; // 设置画布的宽度为512像素
      canvas.height = 512; // 设置画布的高度为512像素
      const ctx = canvas.getContext("2d"); // 获取画布上的绘图上下文对象

      const img = new Image(); // 创建一个图片元素，用来加载用户选择的图片数据，并显示在页面上
      img.onload = async () => {
        // 当图片加载完成后，在画布上绘制压缩后的图片
        ctx.drawImage(img, 0, 0, 512, 512);
        // 获取画布上的图片数据，转换为 Blob 格式
        canvas.toBlob(async (blob) => {
          try {
            // 使用 calculateMD5 函数来计算 Blob 数据的 MD5 值，使用 await 关键字等待 Promise 对象的结果
            const md5 = await this.calculateMD5(blob);

            // 创建一个 FormData 对象，用来存储 multipart 类型的数据
            const formData = new FormData();
            // 将 Blob 数据添加到 FormData 对象中，命名为 image 字段
            formData.append("image", blob);
            // 将 md5 值添加到 FormData 对象中，命名为 md5 参数
            formData.append("md5", md5);

            // 创建一个 AbortController 对象，用来控制请求的取消操作
            const controller = new AbortController();
            // 设置一个定时器，在 60 秒后调用 abort 方法取消请求
            const timer = setTimeout(() => controller.abort(), 60000);

            // 使用 fetch API 发送 POST 请求，将 FormData 数据上传到服务器，并将 signal 参数设置为 controller.signal
            fetch("api/v1/predict", {
              method: "POST",
              body: formData,
              signal: controller.signal,
            })
              .then((res) => res.json()) // 将响应转换为 JSON 格式
              .then((data) => {
                this.progress = 100;
                this.pauseProgress();
                console.log("Response Data:", data); // 打印响应数据
                // 如果响应中有 error 字段，并且不为空，则表示上传失败，显示错误信息
                if (data.error && data.error !== "") {
                  this.error = data.error;
                } else {
                  // 否则表示上传成功，显示推荐内容
                  // 遍历 data.contents 数组中的每一个元素
                  for (let item of data.contents) {
                    // 将 item.thumb_url 中的 i.pximg.net 替换为 i.pixiv.re
                    item.thumb_url = item.thumb_url.replace("i.pximg.net", "i.pixiv.re");
                    // 将 item.profile_img 中的 i.pximg.net 替换为 i.pixiv.re
                    item.profile_img = item.profile_img.replace("i.pximg.net", "i.pixiv.re");
                  }
                  // 将 data.contents 赋值给 this.result
                  this.result = data.contents;
                  // 显示一条提示信息，告诉用户已经成功上传图片，并获取到了推荐内容
                  this.resultMessage = "恭喜你，你已经成功上传了图片，并获取到了以下的推荐内容：";
                }
                this.uploading = false; // 设置上传状态为 false
                this.progress = 100; // 设置进度为 100
                this.timeoutProgress();
                clearTimeout(timer); // 清除定时器
              })
              .catch((err) => {
                this.progress = 100;
                this.pauseProgress();
                console.log("Error:", err); // 打印异常错误信息
                // 如果请求过程中出现异常，显示错误信息，并判断是否是因为超时取消
                if (err.name === "AbortError") {
                  this.error = "请求超时，请稍后再试。";
                } else {
                  this.error = "服务暂不可用，请稍后再试";
                }
                this.uploading = false; // 设置上传状态为 false
                this.progress = 100; // 设置进度为 100
                this.timeoutProgress();
              });
          } catch (error) {
            console.log("Error calculating MD5:", error); // 打印计算 MD5 值过程中出现的错误信息
          }
        }, "image/jpeg", 0.8); // 使用 canvas.toBlob 方法来获取画布上的图片数据，转换为 Blob 格式，指定图片类型为 image/jpeg，质量为 0.8
      };
      img.src = this.image; // 设置图片元素的源为用户选择的图片数据，这里是一个 base64 编码的字符串
    },
    startProgress() {
      this.progress = 0;
      this.timeoutId = setInterval(() => {
        if (this.progress < 99) {
          this.progress += 1;
        } else {
          this.pauseProgress();
        }
      }, 100);
    },

    pauseProgress() {
      clearInterval(this.timeoutId);
      this.timeoutId = null;
    },

    timeoutProgress() {
      this.progress = 100;
      this.pauseProgress();
    },
  },
}; 
</script>
