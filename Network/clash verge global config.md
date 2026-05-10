# clash verge global config

Clash Verge Rev 可以通过 global extend config 和 global extend script 实现重写代理规则、代理组，筛选节点，远程订阅代理规则等功能。

## global extend script

以下 global extend script 仅能实现对 steam、微信、钉钉的代理规则重写：

- steam 的所有流量，无论是商店、社区、下载，全走代理。
- 微信和钉钉的所有流量全走直连。

脚本具体实现参考[clash-script.js](./clash-script.js)

### 需要自定义的部分

#### 修改 profile 名称和 proxy group 名称

这里：

```js
const profilePolicyMap = {
  "Profile A": "Proxy",
  "Profile B": "节点选择",
};
```

比如你的两个 profile，`机场 1`和`机场 2`，`机场 1`的 proxy group 是`PROXY`，`机场 2`proxy group 是`手动选择`的那就改成：

```js
const profilePolicyMap = {
  "机场 1": "PROXY",
  "机场 2": "手动选择",
};
```

---

#### 如果你的代理组名还有别的可能，也可以补进候选列表（可选）

```js
const proxyPolicyCandidates = [
  "Proxy",
  "节点选择",
  "PROXY",
  "GLOBAL",
  "手动切换"
];
```

NOTE: **即使你不做上面两项修改，脚本中还是有兜底，会选择 Policy 中最前面的 select 组作为默认代理组。**

#### 调整 proxy group 中的节点顺序

脚本会重写 `proxy group` 里的节点顺序，但不会改动 `config.proxies` 中的节点定义顺序。

默认优先顺序在 `proxyRegionOrder` 中配置：

```js
const proxyRegionOrder = [
  {
    name: "美国",
    keywords: [
      "美国",
      "美國",
      "United States",
      "USA",
      "US",
      "America",
      "🇺🇸"
    ]
  },
  {
    name: "新加坡",
    keywords: [
      "新加坡",
      "Singapore",
      "SG",
      "🇸🇬"
    ]
  }
];
```

排序规则：

- 越靠前的地区优先级越高。
- 同一地区内保持订阅原顺序。
- 没有命中任何 `keywords` 的节点会排在已配置地区之后，并保持原相对顺序。
- `DIRECT`、`REJECT`、其他 proxy group 名称等非真实节点不会参与排序，会保留在原位置。

如果要调整地区优先级，直接调整 `proxyRegionOrder` 中对象的顺序。如果要增加新的地区，就按同样格式新增一个对象。

#### 从 proxy group 中移除指定节点

脚本会根据 `excludedProxyNameRules` 从 `proxy group` 中删除不需要的真实节点，但不会删除 `config.proxies` 里的节点定义。

当前默认会移除节点名包含 `ipv6` 的节点，匹配时不区分大小写：

```js
const excludedProxyNameRules = [
  {
    name: "IPv6",
    keywords: [
      "ipv6"
    ]
  }
];
```

如果还想删除香港节点，可以这样加：

```js
const excludedProxyNameRules = [
  {
    name: "IPv6",
    keywords: [
      "ipv6"
    ]
  },
  {
    name: "香港",
    keywords: [
      "香港",
      "Hong Kong",
      "HK",
      "🇭🇰"
    ]
  }
];
```

`keywords` 中任意一个字符串命中节点名，就会从 `proxy group` 中移除该节点。这里只影响策略组里的可选项，不会影响订阅中原始节点定义。

#### 自定义 Proxy Rules 和 Direct Rules

```js
function buildProxyRules(proxyPolicy) {
  if (!proxyPolicy) return [];

  // 需要强制走代理的规则放在这里，策略组统一使用当前 profile 解析出的 proxyPolicy。
  return [
    // 示例
    // `DOMAIN-SUFFIX,example.com`
  ];
}

// 需要强制直连的规则放在这里，避免国内服务、办公软件和支付场景误走代理。
const directRules = [
  // 示例
  // `PROCESS-NAME,DingTalk.exe,DIRECT`
];
```

---

## 订阅远程规则

- `rule-providers` 放在“全局扩展配置”里，让 Mihomo 继续按 YAML 配置加载远程规则集。
- `RULE-SET,...` 以及普通前置规则放在“全局扩展脚本”里的 `newRules` 数组。
- 在脚本入口 `main(config)` 中执行 `config.rules = newRules.concat(oldRules)`，把自定义规则插到原订阅规则前面。

### 全局扩展配置里放 `rule-providers`

YAML 具体实现参考[clash-merge.yaml](./clash-merge.yaml)

这些 `rule-providers` 只负责定义规则集来源。真正决定流量走哪个策略组的是 `rules` 里的 `RULE-SET,规则集名,策略组名`。

### 全局扩展脚本里前置 `rules`

```js
// 需要优先生效的规则，等价于旧写法中的 prepend-rules。
const newRules = [
  "RULE-SET,Gemini,代理服务器3",
  "RULE-SET,Bing,代理服务器2",
  "RULE-SET,Openai,代理服务器1",
  "RULE-SET,OneDrive,代理服务器1"
];

function main(config) {
  const oldRules = Array.isArray(config.rules) ? config.rules : [];

  config.rules = newRules.concat(oldRules);

  return config;
}
```

## References

1. [自定义规则脚本](https://www.clashverge.dev/guide/script.html#1)
2. [Issue 1437](https://github.com/clash-verge-rev/clash-verge-rev/issues/1437#issuecomment-2395050752)
