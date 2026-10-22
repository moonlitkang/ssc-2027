import Foundation
import Combine

enum Language: String {
    case en
    case zh
}

/// Two languages, one table.
///
/// English is the default and stays the default: the app is judged by people
/// who are not reading Chinese, so the switch is an explicit control in the
/// corner, never an automatic response to the device locale. Chinese exists so
/// the author, and anyone in the class the piece is about, can read it without
/// English in the way.
///
/// Keys are the English strings themselves. That means a missing translation
/// falls back to English instead of showing a blank or a crash — the safe
/// failure for a submission.
final class L10n: ObservableObject {

    static let shared = L10n()

    @Published private(set) var language: Language

    private static let key = "ui.language"

    private init() {
        let stored = UserDefaults.standard.string(forKey: L10n.key) ?? Language.en.rawValue
        language = Language(rawValue: stored) ?? .en
    }

    func toggle() {
        language = (language == .en) ? .zh : .en
        UserDefaults.standard.set(language.rawValue, forKey: L10n.key)
    }

    /// The label of the control itself, always in the other language.
    var toggleLabel: String {
        language == .en ? "中文" : "EN"
    }

    /// Built here rather than in the view, so the only file that contains
    /// Chinese stays the only file that contains Chinese.
    func rowLabel(_ row: Int) -> String {
        language == .zh ? "第 \(row) 排 / 共 7 排" : "Row \(row) of 7"
    }

    func t(_ english: String) -> String {
        guard language == .zh else { return english }
        return L10n.table[english] ?? english
    }

    private static let table: [String: String] = [
        // Intro
        "Third Row": "第三排",
        "Row 7 of 7.": "七排里的第七排。",
        "Hold the board to squint.\nLet go and it gets worse.": "按住黑板，就是眯眼。\n松开，一切又糊回去。",
        "About three minutes. Sound on.": "大约三分钟。请打开声音。",
        "Sit down": "坐下",

        // The room
        "Solve for x:": "求 x：",
        "Ex. 1-8, odd only": "练习 1-8，只做单数",
        "Hold the board to squint.": "按住黑板，眯着眼看。",
        "Eye strain": "眼睛的疲劳",
        "Row 3.": "第三排。",
        "Row 5.": "第五排。",
        "Row 7.": "第七排。",
        "Two weeks later": "两周后",
        "Ask someone": "问问别人",

        // The three failures
        "You don't have to. Not yet.": "现在还不必。",
        "The problem comes back. The line under it doesn't.": "题目回来了。下面那行没有。",
        "You lean forward until your chair lifts off the floor. You sit back.": "你往前倾，椅子后腿翘了起来。你坐回去。",
        "The shapes get bigger. They don't get sharper.": "字形变大了。没有变清楚。",
        "You try again. Your eyes water.": "你又试了一次。眼睛发酸。",
        "You stop trying.": "你不再试了。",

        // Asking
        "You can't read it. So you ask.": "你看不清。于是你问人。",
        "He couldn't read it either. So you ask someone else.": "他也看不清。于是你换一个人问。",
        "Anyone will do.": "谁都可以。",
        "The boy next to you": "旁边的男生",
        "The girl in front of you": "前排的女生",
        "The teacher": "老师",
        "He reads it out loud.": "他念了出来。",
        "She pushes her notebook over.": "她把本子推过来。",
        "The teacher says: page 42.": "老师说：第四十二页。",

        // What you find out afterwards
        "Then he says: I can't see it either.\nHe copied it from her.": "然后他说：我也看不清。\n他是抄她的。",
        "Her handwriting is smaller than the board.": "她的字比黑板还小。",
        "You open the book.\nThe print is the same size as the board.": "你翻开书。\n上面的字和黑板一样大。",

        // Copying
        "You write it down.": "你抄下来。",
        "You can't check it against the board.": "你没法对着黑板核对。",
        "Put on your glasses": "戴上眼镜",
        "Put the pencil down": "放下笔",

        // The glasses
        "Then someone handed me a pair of glasses.": "后来有人递给我一副眼镜。",
        "It took less than a second.": "不到一秒。",

        // Recap
        "seconds of squinting.": "秒。你一直在眯。",
        "Fifteen pairs of glasses\nin a class of fifty.": "五十人的班里，\n十五副眼镜。",
        "Mine is one of them.": "我是其中一副。",
        "Nobody read it off the board.": "没有人是自己从黑板上看下来的。",
        "We all read it off each other.": "我们都是互相抄的。",
    ]
}
