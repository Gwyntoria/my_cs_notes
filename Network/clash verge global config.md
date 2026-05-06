# clash verge global config

## clash verge 完整脚本

```js
// Clash Verge Rev 全局扩展脚本
// 目的：
// 1. Steam 在 CLOUD / GHELPER 两个 profile 下自动选择对应代理组走代理
// 2. 微信、钉钉、支付宝、京东、淘宝、得到、财新等直连
// 3. 对所有 profile 生效

const directPolicy = "DIRECT";

// profile 名称 -> 代理组名称
const profilePolicyMap = {
  "CLOUD": "🔰 手动选择",
  "GHELPER": "Ghelper",
};

// 如果 profileName 没命中，就按这个候选列表自动找当前配置里存在的组名
const proxyPolicyCandidates = [
  "🔰 手动选择",
  "Ghelper",
  "Proxy",
  "节点选择",
  "🚀 节点选择",
  "PROXY",
  "GLOBAL",
  "代理",
  "手动切换"
];

function uniqueRules(rules) {
  const seen = new Set();
  const result = [];

  for (const rule of rules) {
    if (typeof rule !== "string") continue;
    if (seen.has(rule)) continue;
    seen.add(rule);
    result.push(rule);
  }

  return result;
}

function getProxyGroupNames(config) {
  const groups = Array.isArray(config["proxy-groups"]) ? config["proxy-groups"] : [];

  return groups
    .map(group => group && group.name)
    .filter(Boolean);
}

function resolveProxyPolicy(config, profileName) {
  const groupNames = getProxyGroupNames(config);

  // 1. 先按 profileName 精确匹配
  const mappedPolicy = profilePolicyMap[profileName];
  if (mappedPolicy && groupNames.includes(mappedPolicy)) {
    return mappedPolicy;
  }

  // 2. 再按候选名称自动匹配
  for (const candidate of proxyPolicyCandidates) {
    if (groupNames.includes(candidate)) {
      return candidate;
    }
  }

  // 3. 最后兜底：选第一个看起来像“可出站代理组”的组
  const groups = Array.isArray(config["proxy-groups"]) ? config["proxy-groups"] : [];
  const fallbackGroup = groups.find(group => {
    if (!group || !group.name || !group.type) return false;
    return ["select", "url-test", "fallback", "load-balance"].includes(group.type);
  });

  return fallbackGroup ? fallbackGroup.name : null;
}

function buildSteamRules(proxyPolicy) {
  if (!proxyPolicy) return [];

  return [
    // --- Steam: Windows ---
    `PROCESS-NAME,steam.exe,${proxyPolicy}`,
    `PROCESS-NAME,steamwebhelper.exe,${proxyPolicy}`,
    `PROCESS-NAME,steamservice.exe,${proxyPolicy}`,

    // --- Steam: macOS ---
    `PROCESS-NAME,Steam,${proxyPolicy}`,
    `PROCESS-NAME,steam_osx,${proxyPolicy}`,
    `PROCESS-NAME,steamwebhelper,${proxyPolicy}`,

    // --- Steam 核心域名 ---
    `DOMAIN-SUFFIX,steampowered.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamcommunity.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamgames.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamusercontent.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamcontent.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamstatic.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamserver.net,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steam-chat.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,valvesoftware.com,${proxyPolicy}`,
    `DOMAIN-SUFFIX,valve.net,${proxyPolicy}`,

    // --- 常见下载 / CDN ---
    `DOMAIN-SUFFIX,steamcdn-a.akamaihd.net,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamstore-a.akamaihd.net,${proxyPolicy}`,
    `DOMAIN-SUFFIX,steamusercontent-a.akamaihd.net,${proxyPolicy}`,

    // --- 兜底关键词 ---
    `DOMAIN-KEYWORD,steam,${proxyPolicy}`,
    `DOMAIN-KEYWORD,valve,${proxyPolicy}`
  ];
}

const directRules = [
  `DOMAIN-SUFFIX,caixin.com,${directPolicy}`,
  `DOMAIN-SUFFIX,dedao.com,${directPolicy}`,
  `DOMAIN-SUFFIX,jd.com,${directPolicy}`,
  `DOMAIN-SUFFIX,alipay.com,${directPolicy}`,
  `DOMAIN-SUFFIX,taobao.com,${directPolicy}`,

  // --- 微信 / WeChat: Windows ---
  `PROCESS-NAME,WeChat.exe,${directPolicy}`,
  `PROCESS-NAME,Weixin.exe,${directPolicy}`,
  `PROCESS-NAME,WeChatAppEx.exe,${directPolicy}`,

  // --- 微信 / WeChat: macOS ---
  `PROCESS-NAME,WeChat,${directPolicy}`,
  `PROCESS-NAME,Weixin,${directPolicy}`,

  // --- 钉钉 / DingTalk: Windows ---
  `PROCESS-NAME,DingTalk.exe,${directPolicy}`,

  // --- 钉钉 / DingTalk: macOS ---
  `PROCESS-NAME,DingTalk,${directPolicy}`,

  // --- 微信域名 ---
  `DOMAIN-SUFFIX,qq.com,${directPolicy}`,
  `DOMAIN-SUFFIX,wechat.com,${directPolicy}`,
  `DOMAIN-SUFFIX,weixin.qq.com,${directPolicy}`,
  `DOMAIN-SUFFIX,weixin.com,${directPolicy}`,
  `DOMAIN-SUFFIX,servicewechat.com,${directPolicy}`,
  `DOMAIN-SUFFIX,wx.qq.com,${directPolicy}`,
  `DOMAIN-SUFFIX,gtimg.com,${directPolicy}`,
  `DOMAIN-SUFFIX,qpic.cn,${directPolicy}`,
  `DOMAIN-SUFFIX,qlogo.cn,${directPolicy}`,
  `DOMAIN-SUFFIX,tenpay.com,${directPolicy}`,
  `DOMAIN-SUFFIX,wechatpay.com,${directPolicy}`,

  // --- 钉钉域名 ---
  `DOMAIN-SUFFIX,dingtalk.com,${directPolicy}`,
  `DOMAIN-SUFFIX,dingtalkapps.com,${directPolicy}`,
  `DOMAIN-SUFFIX,alicdn.com,${directPolicy}`,
  `DOMAIN-SUFFIX,aliyuncs.com,${directPolicy}`,
  `DOMAIN-SUFFIX,mxhichina.com,${directPolicy}`,
  `DOMAIN-SUFFIX,mmstat.com,${directPolicy}`,

  // --- 国内兜底 ---
  `GEOSITE,cn,${directPolicy}`,
  `GEOIP,CN,${directPolicy},no-resolve`
];

function main(config, profileName) {
  const oldRules = Array.isArray(config.rules) ? config.rules : [];

  const proxyPolicy = resolveProxyPolicy(config, profileName);
  const steamProxyRules = buildSteamRules(proxyPolicy);

  config.rules = uniqueRules(
    steamProxyRules
      .concat(directRules)
      .concat(oldRules)
  );

  config.dns = config.dns || {};

  const oldFakeIpFilter = Array.isArray(config.dns["fake-ip-filter"])
    ? config.dns["fake-ip-filter"]
    : [];

  const fakeIpFilter = [
    "localhost.ptlogin2.qq.com",
    "localhost.sec.qq.com",
    "localhost.work.weixin.qq.com",
    "*.weixin.qq.com",
    "*.wechat.com",
    "*.dingtalk.com",
    "*.dingtalkapps.com"
  ];

  config.dns["fake-ip-filter"] = uniqueRules(
    fakeIpFilter.concat(oldFakeIpFilter)
  );

  return config;
}
```

---

## 需要自定义的部分

### 1）把 profile 名称改成你自己的

这里：

```js
const profilePolicyMap = {
  "Profile A": "Proxy",
  "Profile B": "节点选择",
};
```

比如如果你的两个 profile 实际叫：

* `机场 1`
* `机场 2`

那就改成：

```js
const profilePolicyMap = {
  "机场 1": "Proxy",
  "机场 2": "节点选择",
};
```

---

### 2）如果你的代理组名还有别的可能，也可以补进候选列表

这里：

```js
const proxyPolicyCandidates = [
  "Proxy",
  "节点选择",
  "PROXY",
  "GLOBAL",
  "手动切换"
];
```
