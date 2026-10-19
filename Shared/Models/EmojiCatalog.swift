import Foundation
import Combine

public struct EmojiCategory: Identifiable, Equatable {
    public let id: String
    public let title: String
    public let icon: String
    public let emojis: [String]
}

public final class EmojiCatalog: ObservableObject {
    public static let shared = EmojiCatalog()

    @Published public private(set) var recentEmojis: [String] = []
    public let categories: [EmojiCategory]
    private let recentsKey = "gbios_recent_emojis_v1"

    private static let defaultRecents: [String] = [
        "🤔", "💀", "🎉", "❤️", "🤞", "😬", "🫣", "💤",
        "😂", "🏠", "😱", "💵", "☣️", "🤪", "👍", "🥲",
        "🙏", "🙅‍♂️", "🤨", "🤷‍♂️", "🤣", "😭", "💊", "😏",
        "🧋", "🤒", "🔥", "✨"
    ]

    private init() {
        if let saved = UserDefaults.standard.stringArray(forKey: recentsKey), !saved.isEmpty {
            self.recentEmojis = saved
        } else {
            self.recentEmojis = Self.defaultRecents
        }

        var builtCategories: [EmojiCategory] = []

        var smileys: [String] = [
            "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "🥲", "☺️",
            "😊", "😇", "🙂", "🙃", "😉", "😌", "😍", "🥰", "😘", "😗",
            "😙", "😚", "😋", "😛", "😝", "😜", "🤪", "🤨", "🧐", "🤓",
            "😎", "🥸", "🤩", "🥳", "😏", "😒", "😞", "😔", "😟", "😕",
            "🙁", "☹️", "😣", "😖", "😫", "😩", "🥺", "😢", "😭", "😤",
            "😠", "😡", "🤬", "🤯", "😳", "🥵", "🥶", "😱", "😨", "😰",
            "😥", "😓", "🤗", "🤔", "🫡", "🤭", "🫢", "🫣", "🤫", "🤥",
            "😶", "🫥", "😐", "😑", "😬", "🫠", "🙄", "😯", "😦", "😧",
            "😮", "😲", "🥱", "😴", "🤤", "😪", "😵", "🤐", "🥴", "🤢",
            "🤮", "🤧", "😷", "🤒", "🤕", "🤑", "🤠", "😈", "👿", "👹",
            "👺", "🤡", "💩", "👻", "💀", "☠️", "👽", "👾", "🤖", "🎃",
            "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾",
            "👋", "🤚", "🖐️", "✋", "🖖", "🫱", "🫲", "🫳", "🫴", "👌",
            "🤌", "🤏", "✌️", "🤞", "🫰", "🤟", "🤘", "🤙", "👈", "👉",
            "👆", "🖕", "👇", "☝️", "🫵", "👍", "👎", "✊", "👊", "🤛",
            "🤜", "👏", "🙌", "🫶", "👐", "🤲", "🤝", "🙏", "✍️", "💅",
            "🤳", "💪", "🦾", "🦵", "🦿", "🦶", "👂", "🦻", "👃", "🧠",
            "🫀", "🫁", "🦷", "🦴", "👀", "👁️", "👅", "👄", "🫦", "👶",
            "🧒", "👦", "👧", "🧑", "👱", "👨", "🧔", "👩", "🧓", "👴",
            "👵", "🙍", "🙎", "🙅", "🙆", "💁", "🙋", "🧏", "🙇", "🤦",
            "🤷", "👮", "🕵️", "💂", "🥷", "👷", "🫅", "🤴", "👸", "👳",
            "👲", "🧕", "🤵", "👰", "🤰", "🫃", "🫄", "🤱", "👼", "🎅",
            "🤶", "🦸", "🦹", "🧙", "🧚", "🧛", "🧜", "🧝", "🧞", "🧟",
            "🧌", "💆", "💇", "🚶", "🧍", "🧎", "🏃", "💃", "🕺", "🕴️",
            "👯", "🧖", "🧗", "🤺", "🏇", "⛷️", "🏂", "🏌️", "🏄", "🚣",
            "🏊", "⛹️", "🏋️", "🚴", "🚵", "🤸", "🤼", "🤽", "🤾", "🤹",
            "🧘", "🛀", "🛌", "👭", "👫", "👬", "💏", "💑", "👪", "🗣️",
            "👤", "👥", "🫂", "👣"
        ]
        smileys.append(contentsOf: Self.emojiScalars(in: 0x1F600...0x1F64F))
        smileys.append(contentsOf: Self.emojiScalars(in: 0x1F910...0x1F93A))
        smileys.append(contentsOf: Self.emojiScalars(in: 0x1F970...0x1F97A))
        builtCategories.append(EmojiCategory(id: "smileys", title: "Smileys & People", icon: "face.smiling", emojis: Self.dedup(smileys)))

        var animals: [String] = [
            "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐻‍❄️", "🐨",
            "🐯", "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊",
            "🐒", "🐔", "🐧", "🐦", "🐤", "🐣", "🐥", "🦆", "🦅", "🦉",
            "🦇", "🐺", "🐗", "🐴", "🦄", "🐝", "🪱", "🐛", "🦋", "🐌",
            "🐞", "🐜", "🪰", "🪲", "🪳", "🦟", "🦗", "🕷️", "🕸️", "🦂",
            "🐢", "🐍", "🦎", "🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀",
            "🪼", "🪸", "🐡", "🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊",
            "🐅", "🐆", "🦓", "🦍", "🦧", "🦣", "🐘", "🦛", "🦏", "🐪",
            "🐫", "🦒", "🦘", "🦬", "🐃", "🐂", "🐄", "🐎", "🐖", "🐏",
            "🐑", "🦙", "🐐", "🦌", "🐕", "🐩", "🦮", "🐕‍🦺", "🐈", "🐈‍⬛",
            "🪶", "🐓", "🦃", "🦤", "🦚", "🦜", "🦢", "🦩", "🕊️", "🐇",
            "🦝", "🦨", "🦡", "🦫", "🦦", "🦥", "🐁", "🐀", "🐿️", "🦔",
            "🐾", "🐉", "🐲", "🌵", "🎄", "🌲", "🌳", "🌴", "🪵", "🌱",
            "🌿", "☘️", "🍀", "🎍", "🪴", "🎋", "🍃", "🍂", "🍁", "🪺",
            "🪹", "🍄", "🐚", "🌾", "💐", "🌷", "🌹", "🥀", "🪷", "🌺",
            "🌸", "🌼", "🌻", "🌞", "🌝", "🌛", "🌜", "🌚", "🌕", "🌖",
            "🌗", "🌘", "🌑", "🌒", "🌓", "🌔", "🌙", "🌎", "🌍", "🌏",
            "🪐", "💫", "⭐️", "🌟", "✨", "⚡️", "☄️", "💥", "🔥", "🌪️",
            "🌈", "☀️", "🌤️", "⛅️", "🌥️", "☁️", "🌦️", "🌧️", "⛈️", "🌩️",
            "🌨️", "❄️", "☃️", "⛄️", "🌬️", "💨", "💧", "💦", "🫧", "☔️",
            "☂️", "🌊", "🌫️"
        ]
        animals.append(contentsOf: Self.emojiScalars(in: 0x1F400...0x1F43F))
        animals.append(contentsOf: Self.emojiScalars(in: 0x1F980...0x1F9AE))
        builtCategories.append(EmojiCategory(id: "animals", title: "Animals & Nature", icon: "pawprint", emojis: Self.dedup(animals)))

        var food: [String] = [
            "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🫐",
            "🍈", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑",
            "🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒", "🧄", "🧅",
            "🥔", "🍠", "🥐", "🥯", "🍞", "🥖", "🥨", "🧀", "🥚", "🍳",
            "🧈", "🥞", "🧇", "🥓", "🥩", "🍗", "🍖", "🦴", "🌭", "🍔",
            "🍟", "🍕", "🫓", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗",
            "🥘", "🫕", "🥫", "🍝", "🍜", "🍲", "🍛", "🍣", "🍱", "🥟",
            "🦪", "🍤", "🍙", "🍚", "🍘", "🍥", "🥠", "🥮", "🍢", "🍡",
            "🍧", "🍨", "🍦", "🥧", "🧁", "🍰", "🎂", "🍮", "🍭", "🍬",
            "🍫", "🍿", "🍩", "🍪", "🌰", "🥜", "🫘", "🍯", "🥛", "🍼",
            "🫖", "☕️", "🍵", "🧃", "🥤", "🧋", "🫙", "🍶", "🍺", "🍻",
            "🥂", "🍷", "🥃", "🍸", "🍹", "🧉", "🍾", "🧊", "🥄", "🍴",
            "🍽️", "🥣", "🥡", "🥢", "🧂"
        ]
        food.append(contentsOf: Self.emojiScalars(in: 0x1F345...0x1F37F))
        food.append(contentsOf: Self.emojiScalars(in: 0x1F950...0x1F96F))
        builtCategories.append(EmojiCategory(id: "food", title: "Food & Drink", icon: "fork.knife", emojis: Self.dedup(food)))

        var activity: [String] = [
            "⚽️", "🏀", "🏈", "⚾️", "🥎", "🎾", "🏐", "🏉", "🥏", "🎱",
            "🪀", "🏓", "🏸", "🏒", "🏑", "🥍", "🏏", "🪃", "🥅", "⛳️",
            "🪁", "🏹", "🎣", "🤿", "🥊", "🥋", "🎽", "🛹", "🛼", "🛷",
            "⛸️", "🥌", "🎿", "⛷️", "🏂", "🪂", "🏋️", "🤼", "🤸", "⛹️",
            "🤺", "🤾", "🏌️", "🏇", "🧘", "🏄", "🏊", "🤽", "🚣", "🧗",
            "🚵", "🚴", "🏆", "🥇", "🥈", "🥉", "🏅", "🎖️", "🏵️", "🎗️",
            "🎫", "🎟️", "🎪", "🤹", "🎭", "🩰", "🎨", "🎬", "🎤", "🎧",
            "🎼", "🎹", "🥁", "🪘", "🎷", "🎺", "🪗", "🎸", "🪕", "🎻",
            "🪈", "🎲", "♟️", "🎯", "🎳", "🎮", "🎰", "🧩", "🎉", "🎊",
            "🎈", "🎂", "🎀", "🎁", "🪄", "🪅", "🪩"
        ]
        activity.append(contentsOf: Self.emojiScalars(in: 0x1F3A0...0x1F3CF))
        builtCategories.append(EmojiCategory(id: "activity", title: "Activity", icon: "soccerball", emojis: Self.dedup(activity)))

        var travel: [String] = [
            "🚗", "🚕", "🚙", "🚌", "🚎", "🏎️", "🚓", "🚑", "🚒", "🚐",
            "🛻", "🚚", "🚛", "🚜", "🦯", "🦽", "🦼", "🛴", "🚲", "🛵",
            "🏍️", "🛺", "🚨", "🚔", "🚍", "🚘", "🚖", "🛞", "🚡", "🚠",
            "🚟", "🚃", "🚋", "🚞", "🚝", "🚄", "🚅", "🚈", "🚂", "🚆",
            "🚇", "🚊", "🚉", "✈️", "🛫", "🛬", "🛩️", "💺", "🛰️", "🚀",
            "🛸", "🚁", "🛶", "⛵️", "🚤", "🛥️", "🛳️", "⛴️", "🚢", "⚓️",
            "🛟", "🪝", "⛽️", "🚧", "🚦", "🚥", "🚏", "🗺️", "🗿", "🗽",
            "🗼", "🏰", "🏯", "🏟️", "🎡", "🎢", "🎠", "⛲️", "⛱️", "🏖️",
            "🏝️", "🏜️", "🌋", "⛰️", "🏔️", "🗻", "🏕️", "⛺️", "🛖", "🏠",
            "🏡", "🏘️", "🏚️", "🏗️", "🏭", "🏢", "🏬", "🏣", "🏤", "🏥",
            "🏦", "🏨", "🏪", "🏫", "🏩", "💒", "🏛️", "⛪️", "🕌", "🕍",
            "🛕", "🕋", "⛩️", "🛤️", "🛣️", "🗾", "🎑", "🏞️", "🌅", "🌄",
            "🌠", "🎇", "🎆", "🌇", "🌆", "🏙️", "🌃", "🌌", "🌉", "🌁"
        ]
        travel.append(contentsOf: Self.emojiScalars(in: 0x1F680...0x1F6C5))
        builtCategories.append(EmojiCategory(id: "travel", title: "Travel & Places", icon: "car", emojis: Self.dedup(travel)))

        var objects: [String] = [
            "⌚️", "📱", "📲", "💻", "⌨️", "🖥️", "🖨️", "🖱️", "🖲️", "🕹️",
            "🗜️", "💽", "💾", "💿", "📀", "📼", "📷", "📸", "📹", "🎥",
            "📽️", "🎞️", "📞", "☎️", "📟", "📠", "📺", "📻", "🎙️", "🎚️",
            "🎛️", "🧭", "⏱️", "⏲️", "⏰", "🕰️", "⌛️", "⏳", "📡", "🔋",
            "🪫", "🔌", "💡", "🔦", "🕯️", "🪔", "🧯", "🛢️", "💸", "💵",
            "💴", "💶", "💷", "🪙", "💰", "💳", "💎", "⚖️", "🪜", "🧰",
            "🪛", "🔧", "🔨", "⚒️", "🛠️", "⛏️", "🪚", "🔩", "⚙️", "🪤",
            "🧱", "⛓️", "🧲", "🔫", "💣", "🧨", "🪓", "🔪", "🗡️", "⚔️",
            "🛡️", "🚬", "⚰️", "🪦", "⚱️", "🏺", "🔮", "📿", "🧿", "🪬",
            "💈", "⚗️", "🔭", "🔬", "🕳️", "🩹", "🩺", "🩻", "🩼", "💊",
            "💉", "🩸", "🧬", "🦠", "🧫", "🧪", "🌡️", "🧹", "🪠", "🧺",
            "🧻", "🚽", "🚰", "🚿", "🛁", "🛀", "🧼", "🪥", "🪒", "🧽",
            "🪣", "🧴", "🛎️", "🔑", "🗝️", "🚪", "🪑", "🛋️", "🛏️", "🛌",
            "🧸", "🪆", "🖼️", "🪞", "🪟", "🛍️", "🛒", "🎁", "🎈", "🎏",
            "🎀", "🪄", "🪅", "🎊", "🎉", "🎎", "🏮", "🎐", "🪩", "✉️",
            "📩", "📨", "📧", "💌", "📥", "📤", "📦", "🏷️", "🪧", "📪",
            "📫", "📬", "📭", "📮", "📯", "📜", "📃", "📄", "📑", "🧾",
            "📊", "📈", "📉", "🗒️", "🗓️", "📆", "📅", "🗑️", "📇", "🗃️",
            "🗳️", "🗄️", "📋", "📁", "📂", "🗂️", "🗞️", "📰", "📓", "📔",
            "📒", "📕", "📗", "📘", "📙", "📚", "📖", "🔖", "🧷", "🔗",
            "📎", "🖇️", "📐", "📏", "🧮", "📌", "📍", "✂️", "🖊️", "🖋️",
            "✒️", "🖌️", "🖍️", "📝", "✏️", "🔍", "🔎", "🔏", "🔐", "🔒",
            "🔓"
        ]
        objects.append(contentsOf: Self.emojiScalars(in: 0x1F4A0...0x1F4FF))
        builtCategories.append(EmojiCategory(id: "objects", title: "Objects", icon: "lightbulb", emojis: Self.dedup(objects)))

        var symbols: [String] = [
            "❤️", "🩷", "🧡", "💛", "💚", "💙", "🩵", "💜", "🖤", "🩶",
            "🤍", "🤎", "💔", "❣️", "💕", "💞", "💓", "💗", "💖", "💘",
            "💝", "💟", "☮️", "✝️", "☪️", "🕉️", "☸️", "✡️", "🔯", "🕎",
            "☯️", "☦️", "🛐", "⛎", "♈️", "♉️", "♊️", "♋️", "♌️", "♍️",
            "♎️", "♏️", "♐️", "♑️", "♒️", "♓️", "🆔", "⚛️", "🉑", "☢️",
            "☣️", "📴", "📳", "🈶", "🈚️", "🈸", "🈺", "🈷️", "✴️", "🆚",
            "💮", "🉐", "㊙️", "㊗️", "🈴", "🈵", "🈹", "🈲", "🅰️", "🅱️",
            "🆎", "🆑", "🅾️", "🆘", "❌", "⭕️", "🛑", "⛔️", "📛", "🚫",
            "💯", "💢", "♨️", "🚷", "🚯", "🚳", "🚱", "🔞", "📵", "🚭",
            "❗️", "❕", "❓", "❔", "‼️", "⁉️", "🔅", "🔆", "〽️", "⚠️",
            "🚸", "🔱", "⚜️", "🔰", "♻️", "✅", "🈯️", "💹", "❇️", "✳️",
            "❎", "🌐", "💠", "Ⓜ️", "🌀", "💤", "🏧", "🚾", "♿️", "🅿️",
            "🛗", "🈳", "🈂️", "🛂", "🛃", "🛄", "🛅", "🚹", "🚺", "🚼",
            "⚧️", "🚻", "🚮", "🎦", "📶", "🈁", "🔣", "ℹ️", "🔤", "🔡",
            "🔠", "🆖", "🆗", "🆙", "🆒", "🆕", "🆓", "0️⃣", "1️⃣", "2️⃣",
            "3️⃣", "4️⃣", "5️⃣", "6️⃣", "7️⃣", "8️⃣", "9️⃣", "🔟", "🔢", "#️⃣",
            "*️⃣", "⏏️", "▶️", "⏸️", "⏯️", "⏹️", "⏺️", "⏭️", "⏮️", "⏩",
            "⏪", "⏫", "⏬", "◀️", "🔼", "🔽", "➡️", "⬅️", "⬆️", "⬇️",
            "↗️", "↘️", "↙️", "↖️", "↕️", "↔️", "↪️", "↩️", "⤴️", "⤵️",
            "🔀", "🔁", "🔂", "🔄", "🔃", "🎵", "🎶", "➕", "➖", "➗",
            "✖️", "🟰", "♾️", "💲", "💱", "™️", "©️", "®️", "〰️", "➰",
            "➿", "🔚", "🔙", "🔛", "🔝", "🔜", "✔️", "☑️", "🔘", "🔴",
            "🟠", "🟡", "🟢", "🔵", "🟣", "⚫️", "⚪️", "🟤", "🔺", "🔻",
            "🔸", "🔹", "🔶", "🔷", "🔳", "🔲", "▪️", "▫️", "◾️", "◽️",
            "◼️", "◻️", "🟥", "🟧", "🟨", "🟩", "🟦", "🟪", "⬛️", "⬜️",
            "🟫", "🔈", "🔇", "🔉", "🔊", "🔔", "🔕", "📣", "📢", "💬",
            "💭", "🗯️", "♠️", "♣️", "♥️", "♦️", "🃏", "🎴", "🀄️"
        ]
        symbols.append(contentsOf: Self.emojiScalars(in: 0x1F500...0x1F53D))
        builtCategories.append(EmojiCategory(id: "symbols", title: "Symbols", icon: "heart", emojis: Self.dedup(symbols)))

        let countryCodes = [
            "US", "GB", "CA", "AU", "NZ", "IE", "FR", "DE", "IT", "ES",
            "PT", "NL", "BE", "LU", "CH", "AT", "SE", "NO", "DK", "FI",
            "IS", "PL", "CZ", "SK", "HU", "RO", "BG", "GR", "TR", "UA",
            "RU", "BY", "EE", "LV", "LT", "HR", "SI", "RS", "BA", "ME",
            "MK", "AL", "MT", "CY", "IL", "SA", "AE", "QA", "KW", "BH",
            "OM", "JO", "LB", "EG", "MA", "DZ", "TN", "ZA", "NG", "KE",
            "GH", "ET", "TZ", "UG", "IN", "PK", "BD", "LK", "NP", "CN",
            "JP", "KR", "TW", "HK", "MO", "SG", "MY", "TH", "VN", "PH",
            "ID", "MM", "KH", "LA", "MN", "KZ", "UZ", "MX", "BR", "AR",
            "CL", "CO", "PE", "VE", "EC", "BO", "PY", "UY", "CR", "PA",
            "DO", "PR", "CU", "JM", "BS", "BB", "TT", "GT", "HN", "SV",
            "NI", "FJ", "PG", "WS", "TO"
        ]
        var flags: [String] = ["🏳️", "🏴", "🏁", "🚩", "🏳️‍🌈", "🏳️‍⚧️", "🏴‍☠️", "🇺🇳"]
        for code in countryCodes {
            flags.append(Self.flagEmoji(for: code))
        }
        builtCategories.append(EmojiCategory(id: "flags", title: "Flags", icon: "flag", emojis: flags))

        self.categories = builtCategories
    }

    public func recordEmojiUsed(_ emoji: String) {
        var updated = recentEmojis.filter { $0 != emoji }
        updated.insert(emoji, at: 0)
        if updated.count > 36 {
            updated = Array(updated.prefix(36))
        }
        recentEmojis = updated
        UserDefaults.standard.set(updated, forKey: recentsKey)
    }

    public func searchEmojis(query: String) -> [String] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return [] }

        var matches: [String] = []
        var seen = Set<String>()
        for cat in categories {
            for emoji in cat.emojis where !seen.contains(emoji) {
                for scalar in emoji.unicodeScalars {
                    if let name = scalar.properties.name, name.contains(trimmed) {
                        matches.append(emoji)
                        seen.insert(emoji)
                        break
                    }
                }
            }
        }
        return matches
    }

    private static func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var s = ""
        for v in countryCode.uppercased().unicodeScalars {
            if let scalar = UnicodeScalar(base + v.value) {
                s.unicodeScalars.append(scalar)
            }
        }
        return s
    }

    private static func emojiScalars(in range: ClosedRange<UInt32>) -> [String] {
        var out: [String] = []
        for code in range {
            if let scalar = UnicodeScalar(code),
               scalar.properties.isEmojiPresentation {
                out.append(String(scalar))
            }
        }
        return out
    }

    private static func dedup(_ items: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        for item in items {
            if !seen.contains(item) {
                seen.insert(item)
                out.append(item)
            }
        }
        return out
    }
}
