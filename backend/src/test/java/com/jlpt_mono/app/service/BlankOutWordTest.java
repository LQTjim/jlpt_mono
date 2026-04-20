package com.jlpt_mono.app.service;

import com.jlpt_mono.app.entity.Word;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BlankOutWordTest {

    private final QuizService quizService = new QuizService(null, null, null, null, null);

    private Word word(String kanji, String hiragana) {
        Word w = new Word();
        w.setKanji(kanji);
        w.setHiragana(hiragana);
        return w;
    }

    @Test
    @DisplayName("完全匹配漢字：食べる → ＿＿＿")
    void exactKanjiMatch() {
        assertThat(quizService.blankOutWord("毎朝食べる。", word("食べる", "たべる")))
                .isEqualTo("毎朝＿＿＿。");
    }

    @Test
    @DisplayName("完全匹配平假名：たべる → ＿＿＿")
    void exactHiraganaMatch() {
        assertThat(quizService.blankOutWord("毎朝たべる。", word(null, "たべる")))
                .isEqualTo("毎朝＿＿＿。");
    }

    @Test
    @DisplayName("漢字詞幹匹配活用形：食べます → ＿＿＿")
    void kanjiStemConjugated() {
        assertThat(quizService.blankOutWord("朝ごはんを食べます。", word("食べる", "たべる")))
                .isEqualTo("朝ごはんを＿＿＿。");
    }

    @Test
    @DisplayName("漢字詞幹匹配 te 形：聞いています → ＿＿＿")
    void kanjiStemTeForm() {
        assertThat(quizService.blankOutWord("音楽を聞いています。", word("聞く", "きく")))
                .isEqualTo("音楽を＿＿＿。");
    }

    @Test
    @DisplayName("漢字詞幹匹配 masu 形：書きます → ＿＿＿")
    void kanjiStemMasuForm() {
        assertThat(quizService.blankOutWord("手紙を書きます。", word("書く", "かく")))
                .isEqualTo("手紙を＿＿＿。");
    }

    @Test
    @DisplayName("平假名詞幹匹配活用形：たべます → ＿＿＿")
    void hiraganaStemConjugated() {
        assertThat(quizService.blankOutWord("朝ごはんをたべます。", word(null, "たべる")))
                .isEqualTo("朝ごはんを＿＿＿。");
    }

    @Test
    @DisplayName("無匹配時回傳原句")
    void noMatch() {
        String sentence = "天気がいいです。";
        assertThat(quizService.blankOutWord(sentence, word("食べる", "たべる")))
                .isEqualTo(sentence);
    }

    @Test
    @DisplayName("kanji 為空時用 hiragana 匹配")
    void emptyKanjiFallsBackToHiragana() {
        assertThat(quizService.blankOutWord("毎朝たべる。", word("", "たべる")))
                .isEqualTo("毎朝＿＿＿。");
    }

    @Test
    @DisplayName("單字元漢字完全匹配：水 → ＿＿＿")
    void singleCharKanji() {
        assertThat(quizService.blankOutWord("水を飲む。", word("水", "みず")))
                .isEqualTo("＿＿＿を飲む。");
    }

    @Test
    @DisplayName("單字元漢字不做詞幹匹配（避免誤切）")
    void singleCharKanjiNoStemMatch() {
        // 水 is 1 char, stem would be empty — should not stem-match
        // If exact match fails, fall back to hiragana
        assertThat(quizService.blankOutWord("おみずを飲む。", word("水", "みず")))
                .isEqualTo("お＿＿＿を飲む。");
    }

    @Test
    @DisplayName("〜前綴計數詞：〜匹 → 匹 → ＿＿＿")
    void tildePrefixCounterWord() {
        assertThat(quizService.blankOutWord("魚を4匹釣りました。", word("〜匹", "ひき")))
                .isEqualTo("魚を4＿＿＿釣りました。");
    }

    @Test
    @DisplayName("〜前綴接續詞：〜から（hiragana fallback 仍正常）")
    void tildePrefixConnector() {
        assertThat(quizService.blankOutWord("東京から来ました。", word("〜から", "から")))
                .isEqualTo("東京＿＿＿来ました。");
    }
}
