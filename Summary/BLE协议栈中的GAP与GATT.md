# BLE 协议栈中的 GAP 和 GATT

| Version | Date       | Description     |
| :------ | :--------- | :-------------- |
| v1.0    | 2023-10-24 | Initial release |

## 1. BLE 概述

低功耗蓝牙（Bluetooth Low Energy, BLE）是建立在客户端/服务器架构（client/server architecture）上的协议，与经典蓝牙（Bluetooth Classic）相比，BLE 消耗更少的功率，需要更少的时间和精力来配对设备，并提供更低的连接速度。

蓝牙协议栈（Bluetooth Protocol Stack）分为两大类：controller 和 host。每个类别都有执行特定角色的子类别。

<img src="../assets/BLE%E5%8D%8F%E8%AE%AE%E6%A0%88%E4%B8%AD%E7%9A%84GAP%E4%B8%8EGATT/ble_stack-16981473070843.svg" alt="ble_stack" style="zoom: 67%;" />

### 1.1. 控制器（Controller）

- 物理层（Physical Layer）：控制器的底层部分，负责处理无线通信的硬件细节，如射频收发、蓝牙频段选择、调制解调等。

- 链路层（Link Layer）：控制器的一部分，处理数据包的传输和接收，以及连接管理和调度广播等操作。

### 1.2. 主机（Host）

- 主机控制接口（Host Controller Interface，HCI）：HCI 是控制器与主机之间的接口，允许主机与控制器通信。HCI 命令用于配置控制器、发送数据和控制低级别蓝牙操作。

- 逻辑链路控制与适配层（Logical Link Control and Adaptation Protocol，L2CAP）：主机的底层部分，用于封装和解封装数据包，管理数据传输的流程控制和适配层协议。

- 通用访问规范（Generic Access Profile，GAP）：GAP 定义了设备的不同角色（例如，中心设备和外围设备）以及广播和连接参数。

- 通用属性规范（Generic Attribute Profile，GATT）：GATT 用于定义蓝牙设备之间的通信协议，包括服务、特征和描述符的定义，以及与这些元素相关的操作。

### 1.3. GAP 和 GATT 有何不同？

- GAP 定义 BLE 网络协议栈的**通用拓扑（general topology）**

- GATT 详细描述了**属性（attributes）/数据（data）**是如何在具有专属链接的设备之间被传输的

GATT 尤其关注如何根据其描述的规则对数据进行格式化、打包和发送。在 BLE 网络堆栈中，属性协议（The Attribute Protocol, ATT）与 GATT 紧密一致，其中 GATT 直接位于 ATT 之上。GATT 实际上使用 ATT 来描述如何从两个连接的设备交换数据。

## 2. Generic Access Profile (GAP)

BLE 设备可以使用两种机制与外界通信：*广播（broadcasting）*或*连接（connecting）*。这些机制受 GAP 指南的约束。GAP 定义了启用 BLE 的设备如何使自己可用，以及两个设备如何直接相互通信，用于管理设备的广播、连接和可见性。

### 2.1. 连接阶段与设备角色

#### 2.1.1. Broadcasting

设备角色之间**不必显式相互连接**即可传输数据。

- 广播者(Broadcaster)：设备向外广播（advertising）特定的数据，以便让发起连接的设备发现这一广播设备。广播数据中包含广播地址及其他广播信息（比如设备名称等）。

  - 外围设备是低功耗的，因为它们只需要定期发送信标.中央设备负责启动与外围设备的通信。

  - GAP 规定了两种广播方式：*可连接广播（Connectable Advertising）*和*不可连接广播（Non-Connectable Advertising）*。

  - 可连接广播用于通知中心设备外围设备的存在，并希望建立连接。不可连接广播只是被 passively 接收，不用于建立连接。

- 观察者(Observer)：设备接收广播数据，并向可扫描广播设备发送扫描请求。广播设备收到扫描请求后会回复一个扫描响应数据。这个过程被称作设备发现（Device Discovery）。broadcaster 和 observer 之间没有连接。

#### 2.1.2. Connecting

设备角色**必须显式连接和握手**才能传输数据。(这些角色比广播角色更常用)

- 外围设备(Peripheral)：能够广播其状态，以便中央设备可以创建连接的设备。连接后，外围设备不再向其他中央设备广播数据，并保持与接受连接请求的设备的连接。

  - 外围设备通常是**被动**的，它们会广播自己的存在，等待中心设备连接。

- 中央设备(Central)：通过首先监听广告数据包来启动与外围设备连接的设备。一个中央设备可以连接到多个外围设备。

  - 中心设备通常是**主动**发起连接的设备，它们扫描周围的广播来查找外围设备，并建立连接。

### 2.2. 连接管理

**中央设备可以更新连接参数(Connection Parameters)**：中央设备通常在外围设备与自身之间创建连接参数。中央设备只能修改连接参数。但是，外围设备可以要求中央设备更改连接参数。

**外围设备或中央设备可以终止连接**：连接可能由于各种原因而终止，如，设备的电池可能会耗尽，或者网络干扰可能会导致连接失败。设备还可以有意断开与对等方的连接。

## 3. The Attribute Protocol (ATT)

### 3.1. Attributes

将被 BLE 客户端请求的数据被以属性（attributes）的形式存储在 BLE 服务器中。

属性是一种数据表示格式，由四个字段组成：

- 属性类型（attribute type），由 UUID 定义。

- 属性句柄（attribute handle），它是属性唯一的无符号数字。

- 属性权限（attribute permissions），用于控制客户端是否可以读取或修改资源。

- 属性值（attribute value）。

#### 3.1.1. 属性类型

*属性类型*指定了此属性表示什么。这是通过使用通用唯一标识符（Universally Unique Identifie, UUID）来实现的。UUID 是一个 128 位的值，某人可以将其分配给一个属性，而无需将其注册到中央管理机构。两个不同的参与者分配相同 UUID 的概率非常低（概率是 1/2128），因此 UUID 被视为唯一的。由于这些设备提供的许多功能是通用的，因此已经为预定义的值保留了一系列 UUID 值，每个值都公开了一组用于常见用例的操作和数据。为了减少数据传输量，这些值的长度为 16 位或 32 位，并且实际的 UUID 是通过使用蓝牙基本 UUID 和一个简单的算术操作来计算的。公式如下：

$$UUID = 16\_or\_32\_bit\_value \times 2^{96} +  Bluetooth\_Base\_UUID$$

#### 3.1.2. 属性句柄

*属性句柄*是一个非零值，用于引用属性。BLE 服务器的所有属性都按照递增的属性句柄值存储在其数据库中。后续属性不必具有下一个整数句柄值，允许在属性句柄值之间存在间隔，但句柄值必须按递增顺序排列。

#### 3.1.3. 属性权限

*属性权限*指定资源是否可以被读取和/或写入，以及所需的安全级别。允许不同的安全组合。例如，某个属性可能对读取不需要权限，但客户端可能需要进行身份验证以便修改资源。

#### 3.1.4. 属性值

*属性值*可以是固定长度或可变长度。对于可变长度属性值，每个 PDU 中只允许发送一个属性值。如果值过长，可以将其分割成多个 PDU。

还有一种特殊类型的属性，不允许读取，但可以写入、通知或指示（我们将在后面讨论最后两种操作）。这些被称为控制点属性，因为它们主要用于应用程序控制，而不是在设备之间传递数据。

## 4. Generic Attribute Profile (GATT)

GATT 是建立在 GAP 之上的协议，用于定义蓝牙设备之间的**数据交换方式**和**数据格式**。

### 4.1. GATT 角色

从 GATT 的角度来看，当两个设备处于连接状态时，一个设备作为 GATT 服务端（server），另一个设备作为 GATT 客户端（client）。

- GATT 客户端：设备发起命令、请求，并接收响应、通知和指示。
- GATT 服务端：设备接收命令、请求，并发出响应、通知和指示。

GATT 服务端通常是 BLE 外设，例如传感器、手表、健身追踪器，而 GATT 客户端通常是中央设备，例如智能手机、平板电脑。

**NOTE:** 这种角色的分配与 GAP 层设备角色（外围设备、中央设备）无关。一个外围设备既可以充当 GATT 客户端，也可以充当 GATT 服务端；一个中央设备同样既可以充当 GATT 客户端，也可以充当 GATT 服务端。

**NOTE:** 在网络术语中，服务器保存资源，如心率测量值或电池电量。客户端使用一些称为服务的预定义操作从服务器请求这些资源，如果请求受支持，服务器将以指定的格式进行响应。

### 4.2. Profile

GATT 使用 ATT 协议来定义访问服务器上的资源的更高级抽象。更正式地说，它是一个服务框架，定义了服务（services）及其特征（characteristics）的过程（procedures）和格式（formats）。典型的设备用例被标准化为。例如，一个常见的 BLE profile 是 Human Interface Device (HID) Profile，广泛用于鼠标和键盘等设备。

Profile 使不同供应商的产品之间实现互操作性成为可能。软件必须提供一组预定义的功能和数据访问点以符合 Profile，这保证了该设备可以与支持相同 Profile 的另一个设备一起运行。此外，每个操作或数据表示都使用 ATT 协议的属性和方法来描述，这种一致性允许重用软件的一部分，并最小化内存占用和开发工作量，同时提高软件维护性。

GATT Profile 结构如下：

<img src="../assets/BLE%E5%8D%8F%E8%AE%AE%E6%A0%88%E4%B8%AD%E7%9A%84GAP%E4%B8%8EGATT/gatt_profile.png" alt="GATT Profile structure"  />

### 4.3. Service

GATT 定义了 BLE 服务器数据库的分层模型。在顶层是 Profile，它们规定了设备支持的用例。Profile 包含服务，**描述服务器支持的特定功能**。服务还提供了一种分组机制，通过引用它们，其他服务可以包含它们。这样，两个或多个 Profile 可以再使用同一服务。服务可以是强制性的或可选的。符合特定 Profile 的每个设备必须实现所有强制性服务。服务分为两种类型：

- 主要服务(Primary services)，公开设备的主要功能。主要服务可以使用主要服务发现过程来发现。
- 次要服务(Secondary services)，用于辅助功能。

每个服务可以具有一个或多个特征，而每个服务通过唯一的数字 ID（UUID）与其他服务区分开来。对于官方采用的 BLE 服务，UUID 的长度为 16 位，而对于自定义服务，长度为 128 位。

### 4.4. Characteristic

特征是一些属性的集合，通常被用于表示设备的某个特定特性或功能。

特征的属性被设置为以下参数：

- 属性类型设置为“Characteristic”（双角引号表示这是由蓝牙 SIG 定义的 UUID）。

- 属性值由三个位字段组成：特征属性（1 octet）、特征值句柄（2 octets）和特征 UUID（2 or 16 octets）。特征属性位字段（Characteristic Properties bitfield）显示了特征值可以如何使用或其描述符可以如何访问。它可以是广播、读取、无响应写（Write Without Response）、写、通知（Notify）、指示（Indicate）、已验证签名写入（Authenticated Signed Writes）或扩展属性。特征值句柄是用于访问特征值的属性句柄。特征 UUID 是特征值的 UUID。

- 属性权限必须可读，不需要身份验证或授权。

紧随特征声明之后的是特征值声明。对于这个属性，其字段为：

- 属性类型与特征声明中的 UUID 相同。

- 属性值为特征值。

- 属性权限是特定于实现的。

## 5. 连接过程

一般情况下，建立两台蓝牙设备之间的通讯需要首先实现 GAP，然后再实现 GATT。下面是建立蓝牙通信的一般步骤：

### 5.1. GAP 阶段

1. 在 GAP 阶段，设备首先确定其角色，即中心设备（Central）或外围设备（Peripheral）。
2. 外围设备通常会开始广播自己的存在，以使中心设备能够发现它。
3. 中心设备会扫描并连接到外围设备，建立连接（由中心设备发起连接请求）。
4. GAP 还涉及连接参数的协商，例如连接间隔和超时等。

### 5.2. GATT 阶段

1. 一旦连接建立，设备之间可以开始使用 GATT 来定义数据传输的方式和数据格式。
2. 在 GATT 中，设备将其功能和数据组织成服务和属性的形式，然后公开这些服务和属性给其他设备。
3. 中心设备可以使用 GATT 协议来读取或写入外围设备的属性，实现数据传输和设备控制。

## 6. References

1. [Intro to Bluetooth Generic Attribute Profile (GATT)](https://www.bluetooth.com/bluetooth-resources/intro-to-bluetooth-gap-gatt/)

2. [BLE-Stack User’s Guide](https://software-dl.ti.com/lprf/simplelink_cc2640r2_latest/docs/blestack/ble_user_guide/html/ble-stack-3.x/overview.html)

3. [How GAP and GATT Work](https://punchthrough.com/how-gap-and-gatt-work/)

4. [GR551x BLE Stack用户指南](https://docs.goodix.com/zh/online/detail/gr55xx_ble_stack_user_guide/V1.9/a1c6a5aa34585b3abb06d1473425b62b)
