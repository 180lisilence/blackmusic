/**
 * 黑马云音乐 —— 后端 API（零依赖，纯 Node http）
 * 部署：/www/wwwroot/heimamusic/server.js，pm2 托管，监听 127.0.0.1:3102
 * 对外：nginx 反代 http://<host>/music/ → http://127.0.0.1:3102/
 *
 * 路由：
 *   GET /health
 *   GET /swiper          轮播
 *   GET /dailyRecommend  每日推荐
 *   GET /recommendList   推荐歌单
 *   GET /songList        歌曲列表
 *   GET /momentList      动态
 *   GET /images/<file>   封面图
 *   GET /audio/<file>    音频（预留）
 */
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3102;
const HOST = '127.0.0.1';
const DATA = path.join(__dirname, 'data');
const PUB = path.join(__dirname, 'public');

const MIME = {
  '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png',
  '.svg': 'image/svg+xml', '.mp3': 'audio/mpeg', '.m4a': 'audio/mp4',
  '.wav': 'audio/wav', '.json': 'application/json; charset=utf-8'
};

const ROUTES = {
  '/swiper': 'swiper.json',
  '/dailyRecommend': 'daily.json',
  '/recommendList': 'playlists.json',
  '/songList': 'songs.json',
  '/momentList': 'moments.json'
};

function send(res, code, body, type, extra) {
  const headers = Object.assign({
    'Content-Type': type || 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': '*',
    'Cache-Control': 'no-cache'
  }, extra || {});
  res.writeHead(code, headers);
  res.end(body);
}

function readJson(name) {
  try {
    return JSON.parse(fs.readFileSync(path.join(DATA, name), 'utf8'));
  } catch (e) {
    return null;
  }
}

const server = http.createServer((req, res) => {
  const url = decodeURIComponent((req.url || '/').split('?')[0]);
  const rid = Date.now().toString(36);
  console.log(rid, req.method, url, req.headers['user-agent'] || '-');

  if (req.method === 'OPTIONS') {
    return send(res, 204, '');
  }

  if (url === '/health' || url === '/') {
    return send(res, 200, JSON.stringify({
      ok: true, service: 'heimamusic-api', ts: Date.now(),
      routes: Object.keys(ROUTES)
    }));
  }

  if (ROUTES[url]) {
    const data = readJson(ROUTES[url]);
    if (data === null) {
      return send(res, 500, JSON.stringify({ code: 500, msg: 'data missing: ' + ROUTES[url] }));
    }
    return send(res, 200, JSON.stringify({ code: 0, data: data, total: data.length }));
  }

  if (url.startsWith('/images/') || url.startsWith('/audio/')) {
    const file = path.join(PUB, path.normalize(url).replace(/^(\.\.[\/\\])+/, ''));
    if (file.startsWith(PUB) && fs.existsSync(file) && fs.statSync(file).isFile()) {
      const ext = path.extname(file).toLowerCase();
      return send(res, 200, fs.readFileSync(file), MIME[ext] || 'application/octet-stream');
    }
    return send(res, 404, JSON.stringify({ code: 404, msg: 'file not found', path: url }));
  }

  send(res, 404, JSON.stringify({ code: 404, msg: 'not found', path: url, routes: Object.keys(ROUTES) }));
});

server.listen(PORT, HOST, () => {
  console.log('heimamusic api listening on http://' + HOST + ':' + PORT);
});
