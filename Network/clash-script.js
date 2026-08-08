// profile 名称 -> 代理组名称
const profilePolicyMap = {
  CLOUD: "🔰 手动选择",
  GHELPER: "Ghelper",
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
  "手动切换",
];

// proxy group 中订阅节点优先顺序。命中这些地区的节点会排在前面，同一地区内保持原订阅顺序。
const proxyRegionOrder = [
  {
    name: "香港",
    keywords: ["香港", "香港", "Hong Kong", "HK", "🇭🇰"],
  },
  {
    name: "美国",
    keywords: ["美国", "美國", "United States", "USA", "US", "America", "🇺🇸"],
  },
  {
    name: "日本",
    keywords: ["日本", "Japan", "JP", "Tokyo", "Osaka", "🇯🇵"],
  },
  {
    name: "韩国",
    keywords: ["韩国", "韓國", "South Korea", "Korea", "KR", "Seoul", "🇰🇷"],
  },
  {
    name: "台湾",
    keywords: ["台湾", "台灣", "Taiwan", "TW"],
  },
  {
    name: "新加坡",
    keywords: ["新加坡", "Singapore", "SG", "🇸🇬"],
  },
];

// 只保留命中这些规则的订阅节点。空数组表示关闭 include 筛选。
const includedProxyNameRules = [
  {
    name: "香港",
    keywords: ["香港", "Hong Kong", "🇭🇰"],
    codes: ["HK"],
  },
  {
    name: "美国",
    keywords: ["美国", "美國", "United States", "America", "🇺🇸"],
    codes: ["US", "USA"],
  },
  {
    name: "日本",
    keywords: ["日本", "Japan", "Tokyo", "Osaka", "🇯🇵"],
    codes: ["JP"],
  },
  {
    name: "韩国",
    keywords: ["韩国", "韓國", "South Korea", "Korea", "Seoul", "🇰🇷"],
    codes: ["KR"],
  },
  {
    name: "新加坡",
    keywords: ["新加坡", "Singapore", "🇸🇬"],
    codes: ["SG"],
  },
  {
    name: "台湾",
    keywords: ["台湾", "台灣", "Taiwan"],
    codes: ["TW"],
  },
];

// 从 proxy groups 里移除不需要的节点。
const excludedProxyNameRules = [
  // 示例：
  // {
  //   name: "测试节点",
  //   keywords: ["test", "测试"]
  // },
  {
    name: "IPv6",
    keywords: ["ipv6"],
  },
];

// 需要强制直连的规则放在这里，避免国内服务、办公软件和支付场景误走代理。
const directRules = [
  `DOMAIN-SUFFIX,epic.com,DIRECT`,
  `DOMAIN-SUFFIX,caixin.com,DIRECT`,
  `DOMAIN-SUFFIX,dedao.com,DIRECT`,
  `DOMAIN-SUFFIX,alipay.com,DIRECT`,
  `DOMAIN-SUFFIX,jd.com,DIRECT`,
  `DOMAIN-SUFFIX,taobao.com,DIRECT`,
  `DOMAIN-SUFFIX,linuxdo.org,DIRECT`,

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
  `GEOIP,CN,DIRECT,no-resolve`,
];

// 需要强制走代理的规则放在这里，策略组统一使用当前 profile 解析出的 proxyPolicy。
const proxyRulePrefixes = [
  "RULE-SET,Openai",
  "RULE-SET,Gemini",

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

  return proxyRulePrefixes.map((rule) => `${rule},${proxyPolicy}`);
}

const fakeIpFilterRules = [
  "localhost.ptlogin2.qq.com",
  "localhost.sec.qq.com",
  "localhost.work.weixin.qq.com",
  "*.weixin.qq.com",
  "*.wechat.com",
  "*.dingtalk.com",
  "*.dingtalkapps.com",
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

  return groups.map((group) => group && group.name).filter(Boolean);
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
  const fallbackGroup = groups.find((group) => {
    if (!group || !group.name || !group.type) return false;
    return ["select", "url-test", "fallback", "load-balance"].includes(
      group.type,
    );
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
    console.warn(
      "[clash-verge] No proxy policy found. Proxy rules were skipped.",
    );
  }

  const proxyRules = buildProxyRules(proxyPolicy);

  config.rules = uniqueRules(directRules.concat(proxyRules).concat(oldRules));
}

function ensureDns(config) {
  config.dns = config.dns || {};

  return config.dns;
}

function getOldFakeIpFilter(dns) {
  return Array.isArray(dns["fake-ip-filter"]) ? dns["fake-ip-filter"] : [];
}

function mergeFakeIpFilter(config) {
  const dns = ensureDns(config);
  const oldFakeIpFilter = getOldFakeIpFilter(dns);

  dns["fake-ip-filter"] = uniqueRules(
    fakeIpFilterRules.concat(oldFakeIpFilter),
  );
}

function getProxyName(proxy) {
  return proxy && typeof proxy.name === "string" ? proxy.name : "";
}

function getProxyRegionRank(proxyName) {
  for (let index = 0; index < proxyRegionOrder.length; index += 1) {
    const region = proxyRegionOrder[index];
    const matched = region.keywords.some((keyword) =>
      proxyName.includes(keyword),
    );

    if (matched) {
      return index;
    }
  }

  return proxyRegionOrder.length;
}

function hasProxyCode(proxyName, code) {
  const normalizedProxyName = proxyName.toUpperCase();
  const normalizedCode = code.toUpperCase();
  let matchIndex = normalizedProxyName.indexOf(normalizedCode);

  while (matchIndex !== -1) {
    const previousCharacter = normalizedProxyName[matchIndex - 1] || "";
    const nextCharacter =
      normalizedProxyName[matchIndex + normalizedCode.length] || "";
    const hasLetterBefore = /[A-Z]/.test(previousCharacter);
    const hasLetterAfter = /[A-Z]/.test(nextCharacter);

    // 地区代码两侧不能紧邻英文字母，避免把 "RUS" 之类的片段误判为 "US"。
    if (!hasLetterBefore && !hasLetterAfter) return true;

    matchIndex = normalizedProxyName.indexOf(normalizedCode, matchIndex + 1);
  }

  return false;
}

function matchesProxyNameRule(proxyName, rule) {
  const normalizedProxyName = proxyName.toLowerCase();
  const keywords = Array.isArray(rule.keywords) ? rule.keywords : [];
  const codes = Array.isArray(rule.codes) ? rule.codes : [];

  const matchesKeyword = keywords.some((keyword) => {
    return normalizedProxyName.includes(keyword.toLowerCase());
  });

  return matchesKeyword || codes.some((code) => hasProxyCode(proxyName, code));
}

function shouldIncludeProxyName(proxyName) {
  if (typeof proxyName !== "string") return false;

  // 未配置 include 规则时不限制节点，便于仅使用 exclude 规则。
  if (includedProxyNameRules.length === 0) return true;

  return includedProxyNameRules.some((rule) => {
    return matchesProxyNameRule(proxyName, rule);
  });
}

function shouldExcludeProxyName(proxyName) {
  if (typeof proxyName !== "string") return false;

  return excludedProxyNameRules.some((rule) => {
    return matchesProxyNameRule(proxyName, rule);
  });
}

function compareProxyRegion(left, right) {
  if (left.rank !== right.rank) {
    return left.rank - right.rank;
  }

  return left.index - right.index;
}

function getProxyNameSet(config) {
  if (!Array.isArray(config.proxies)) return new Set();

  return new Set(config.proxies.map(getProxyName).filter(Boolean));
}

function filterAndSortProxyGroupProxies(config) {
  const proxyNames = getProxyNameSet(config);
  if (proxyNames.size === 0) return;

  for (const group of getProxyGroups(config)) {
    if (!group || !Array.isArray(group.proxies)) continue;

    // 只跟踪订阅节点，策略组引用、DIRECT、REJECT 等固定项不参与筛选。
    const hadProxyNode = group.proxies.some((proxyName) =>
      proxyNames.has(proxyName),
    );

    group.proxies = group.proxies.filter((proxyName) => {
      // 非订阅项必须保留，否则可能破坏代理组之间的引用关系。
      if (!proxyNames.has(proxyName)) return true;

      return shouldIncludeProxyName(proxyName);
    });

    group.proxies = group.proxies.filter((proxyName) => {
      if (!proxyNames.has(proxyName)) return true;

      return !shouldExcludeProxyName(proxyName);
    });

    const hasProxyNode = group.proxies.some((proxyName) =>
      proxyNames.has(proxyName),
    );

    // 仅当原组含订阅节点且筛选后清空时告警，避免对纯策略组误报。
    if (hadProxyNode && !hasProxyNode) {
      console.warn(
        `[clash-verge] No proxy nodes remain in group "${group.name || "<unnamed>"}" after include/exclude filtering.`,
      );
    }

    const sortedProxyNames = group.proxies
      .map((proxyName, index) => ({
        proxyName,
        index,
        rank:
          typeof proxyName === "string"
            ? getProxyRegionRank(proxyName)
            : proxyRegionOrder.length,
      }))
      .filter((item) => proxyNames.has(item.proxyName))
      .sort(compareProxyRegion)
      .map((item) => item.proxyName);

    let sortedIndex = 0;
    group.proxies = group.proxies.map((proxyName) => {
      // 非订阅项保留原位置，只依次替换订阅节点所在的槽位。
      if (!proxyNames.has(proxyName)) {
        return proxyName;
      }

      const sortedProxyName = sortedProxyNames[sortedIndex];
      sortedIndex += 1;

      return sortedProxyName;
    });
  }
}

function main(config, profileName) {
  filterAndSortProxyGroupProxies(config);
  mergeProxyRules(config, profileName);
  mergeFakeIpFilter(config);

  return config;
}
