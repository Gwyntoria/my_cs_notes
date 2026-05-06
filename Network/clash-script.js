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

// 需要强制直连的规则放在这里，避免国内服务、办公软件和支付场景误走代理。
const directRules = [
  `DOMAIN-SUFFIX,epic.com,DIRECT`,
  `DOMAIN-SUFFIX,caixin.com,DIRECT`,
  `DOMAIN-SUFFIX,dedao.com,DIRECT`,
  `DOMAIN-SUFFIX,alipay.com,DIRECT`,
  `DOMAIN-SUFFIX,jd.com,DIRECT`,
  `DOMAIN-SUFFIX,taobao.com,DIRECT`,

  // --- 微信 / WeChat: Windows ---
  `PROCESS-NAME,Weixin.exe,DIRECT`,
  `PROCESS-NAME,WeChat.exe,DIRECT`,
  `PROCESS-NAME,WeChatAppEx.exe,DIRECT`,

  // --- 微信 / WeChat: macOS ---
  `PROCESS-NAME,Weixin,DIRECT`,
  `PROCESS-NAME,WeChat,DIRECT`,

  // --- 钉钉 / DingTalk: Windows ---
  `PROCESS-NAME,DingTalk.exe,DIRECT`,

  // --- 钉钉 / DingTalk: macOS ---
  `PROCESS-NAME,DingTalk,DIRECT`,

  // --- 微信域名 ---
  `DOMAIN-SUFFIX,wechat.com,DIRECT`,
  `DOMAIN-SUFFIX,weixin.qq.com,DIRECT`,
  `DOMAIN-SUFFIX,weixin.com,DIRECT`,
  `DOMAIN-SUFFIX,servicewechat.com,DIRECT`,
  `DOMAIN-SUFFIX,wx.qq.com,DIRECT`,
  `DOMAIN-SUFFIX,gtimg.com,DIRECT`,
  `DOMAIN-SUFFIX,qpic.cn,DIRECT`,
  `DOMAIN-SUFFIX,qlogo.cn,DIRECT`,
  `DOMAIN-SUFFIX,tenpay.com,DIRECT`,
  `DOMAIN-SUFFIX,wechatpay.com,DIRECT`,

  // --- 钉钉域名 ---
  `DOMAIN-SUFFIX,dingtalk.com,DIRECT`,
  `DOMAIN-SUFFIX,dingtalkapps.com,DIRECT`,
  `DOMAIN-SUFFIX,alicdn.com,DIRECT`,
  `DOMAIN-SUFFIX,aliyuncs.com,DIRECT`,
  `DOMAIN-SUFFIX,mxhichina.com,DIRECT`,
  `DOMAIN-SUFFIX,mmstat.com,DIRECT`,

  // --- 国内兜底 ---
  `GEOSITE,cn,DIRECT`,
  `GEOIP,CN,DIRECT,no-resolve`
];

// 需要强制走代理的规则放在这里，策略组统一使用当前 profile 解析出的 proxyPolicy。
const proxyRulePrefixes = [
  // --- Steam: Windows ---
  "PROCESS-NAME,steam.exe",
  "PROCESS-NAME,steamwebhelper.exe",
  "PROCESS-NAME,steamservice.exe",

  // --- Steam: macOS ---
  "PROCESS-NAME,Steam",
  "PROCESS-NAME,steam_osx",
  "PROCESS-NAME,steamwebhelper",

  // --- Steam 核心域名 ---
  "DOMAIN-SUFFIX,steampowered.com",
  "DOMAIN-SUFFIX,steamcommunity.com",
  "DOMAIN-SUFFIX,steamgames.com",
  "DOMAIN-SUFFIX,steamusercontent.com",
  "DOMAIN-SUFFIX,steamcontent.com",
  "DOMAIN-SUFFIX,steamstatic.com",
  "DOMAIN-SUFFIX,steamserver.net",
  "DOMAIN-SUFFIX,steam-chat.com",
  "DOMAIN-SUFFIX,valvesoftware.com",
  "DOMAIN-SUFFIX,valve.net",

  // --- 常见下载 / CDN ---
  "DOMAIN-SUFFIX,steamcdn-a.akamaihd.net",
  "DOMAIN-SUFFIX,steamstore-a.akamaihd.net",
  "DOMAIN-SUFFIX,steamusercontent-a.akamaihd.net",

  // --- 兜底关键词 ---
  "DOMAIN-KEYWORD,steam",
  "DOMAIN-KEYWORD,valve",

  // --- 其他代理规则 ---
  // 示例："DOMAIN-SUFFIX,example.com"
];

function buildProxyRules(proxyPolicy) {
  if (!proxyPolicy) return [];

  return proxyRulePrefixes.map(rule => `${rule},${proxyPolicy}`);
}

const fakeIpFilterRules = [
  "localhost.ptlogin2.qq.com",
  "localhost.sec.qq.com",
  "localhost.work.weixin.qq.com",
  "*.weixin.qq.com",
  "*.wechat.com",
  "*.dingtalk.com",
  "*.dingtalkapps.com"
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

function getProxyGroups(config) {
  return Array.isArray(config["proxy-groups"]) ? config["proxy-groups"] : [];
}

function getProxyGroupNames(config) {
  const groups = getProxyGroups(config);

  return groups
    .map(group => group && group.name)
    .filter(Boolean);
}

function resolveProxyPolicy(config, profileName) {
  const groupNames = new Set(getProxyGroupNames(config));

  // 1. 先按 profileName 精确匹配
  const mappedPolicy = profilePolicyMap[profileName];
  if (mappedPolicy && groupNames.has(mappedPolicy)) {
    return mappedPolicy;
  }

  // 2. 再按候选名称自动匹配
  for (const candidate of proxyPolicyCandidates) {
    if (groupNames.has(candidate)) {
      return candidate;
    }
  }

  // 3. 最后兜底：选第一个看起来像“可出站代理组”的组
  const groups = getProxyGroups(config);
  const fallbackGroup = groups.find(group => {
    if (!group || !group.name || !group.type) return false;
    return ["select", "url-test", "fallback", "load-balance"].includes(group.type);
  });

  return fallbackGroup ? fallbackGroup.name : null;
}

function getOldRules(config) {
  return Array.isArray(config.rules) ? config.rules : [];
}

function mergeProxyRules(config, profileName) {
  const oldRules = getOldRules(config);

  const proxyPolicy = resolveProxyPolicy(config, profileName);
  if (!proxyPolicy) {
    console.warn("[clash-verge] No proxy policy found. Proxy rules were skipped.");
  }

  const proxyRules = buildProxyRules(proxyPolicy);

  config.rules = uniqueRules(
    directRules
      .concat(proxyRules)
      .concat(oldRules)
  );
}

function ensureDns(config) {
  config.dns = config.dns || {};

  return config.dns;
}

function getOldFakeIpFilter(dns) {
  return Array.isArray(dns["fake-ip-filter"])
    ? dns["fake-ip-filter"]
    : [];
}

function mergeFakeIpFilter(config) {
  const dns = ensureDns(config);
  const oldFakeIpFilter = getOldFakeIpFilter(dns);

  dns["fake-ip-filter"] = uniqueRules(
    fakeIpFilterRules.concat(oldFakeIpFilter)
  );
}

function main(config, profileName) {
  mergeProxyRules(config, profileName);
  mergeFakeIpFilter(config);

  return config;
}
