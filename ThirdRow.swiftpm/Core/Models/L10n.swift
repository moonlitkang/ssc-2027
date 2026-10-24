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

    /// The school-year conversion. Six lessons a day, five days a week, forty
    /// weeks — so one second of squinting per lesson is 1/3 of an hour a year.
    func hoursPerYear(_ hours: Int) -> String {
        language == .zh
            ? "照这样算，一年是 \(hours) 小时。"
            : "At that rate, \(hours) hours a year."
    }

    /// The second measured fact on the ending card, and the only one the player
    /// made with their hands.
    func inkLine(strokes: Int, centimetres: Int) -> String {
        if language == .zh {
            return "\(strokes) 笔、\(centimetres) 厘米铅笔，你一笔也没有核对。"
        }
        let unit = strokes == 1 ? "stroke" : "strokes"
        return "\(strokes) \(unit) and \(centimetres) centimetres of pencil,\nand you checked none of it."
    }

    /// The count of times the pencil came off the page long enough to be a look
    /// rather than a movement. It is stated flatly and without interpretation:
    /// the player was there, they know what they were doing during those gaps.
    ///
    /// Zero is reported too, and not as a failure — writing the whole thing
    /// without stopping means the board was never consulted, which is its own
    /// kind of copying.
    func pauseLine(pauses: Int) -> String {
        if pauses == 0 {
            return language == .zh
                ? "你一口气写完，笔没有停过。"
                : "You wrote it in one go.\nYour pencil never stopped."
        }
        if language == .zh {
            return "你的笔停了 \(pauses) 次。黑板一次都没变。"
        }
        let unit = pauses == 1 ? "time" : "times"
        return "Your pencil stopped \(pauses) \(unit).\nThe board did not change once."
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
        "Press and hold the board.": "按住黑板。",
        "Eye strain": "眼睛的疲劳",
        "September.": "九月。",
        "October.": "十月。",
        "December.": "十二月。",
        "Two weeks later": "两周后",
        "Two months later": "两个月后",
        "Ask someone": "问问别人",

        // The three failures
        "You don't have to. Not yet.": "现在还不必。",
        "You can still make out the problem. The line under it is gone.": "题目还看得出轮廓。下面那行没了。",
        "You lean forward until your chair lifts off the floor. You sit back.": "你往前倾，椅子后腿翘了起来。你坐回去。",
        "The shapes get bigger. They don't get sharper.": "字形变大了。没有变清楚。",
        "In November they moved your seat again. In December it was the last row.": "十一月学校又给你换了座位。十二月，是最后一排。",
        "You try again. Your eyes water.": "你又试了一次。眼睛发酸。",
        "You stop trying.": "你不再试了。",

        // Asking
        "You can't read it. So you ask.": "你看不清。于是你问人。",
        "That answer was second-hand too. So you ask someone else.": "那个答案也是二手抄来的。于是你换一个人问。",
        "A page number is not an answer.": "一个页码不是答案。",
        "Anyone will do.": "谁都可以。",
        "The boy next to you": "旁边的男生",
        "The girl in front of you": "前排的女生",
        "The teacher": "老师",
        "He reads it out loud.": "他念了出来。",
        "She pushes her notebook over.": "她把本子推过来。",
        "The teacher says: page 42.": "老师说：第四十二页。",

        // What you find out afterwards
        "Then he says he can't see it either.\nHe has been copying from her since September.": "然后他说他也看不清。\n他从九月起就一直在抄她的。",
        "Her handwriting is smaller than the board.\nShe fits two subjects into one notebook.": "她的字比黑板还小。\n她把两门课挤在一个本子里。",
        "She reads the page out. Before she does, she squints at it.\nShe doesn't mention it.": "她把那一页念出来。念之前，她眯了一下眼。\n她没有提这件事。",
        "There was one more person in the room.": "教室里还有一个人。",

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
        "Six lessons a day, five days a week, forty weeks.": "一天六节课，一周五天，一学年四十周。",
        "Fifteen pairs of glasses\nin a class of fifty.": "五十人的班里，\n十五副眼镜。",
        "Mine is one of them.": "我是其中一副。",
        "Seventy-one percent of junior high students in China are short-sighted.": "中国初中生的近视率是 71%。",
        "Source: National Health Commission, 2024.": "数据来源：国家卫生健康委员会，2024。",
        "Nobody read it off the board.": "没有人是自己从黑板上看下来的。",
        "We all read it off each other.": "我们都是互相抄的。",
        "Nobody in that room thought the room was the problem.": "那间教室里，没有人觉得问题出在教室。",

        // The page you wrote on
        "What you wrote down.": "你写下来的。",
        "You didn't write it down.": "你没有写。",
    ]
}
