// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'AdTech クイズ';

  @override
  String get welcomeTitle => 'AdTech クイズへようこそ！';

  @override
  String get welcomeSubtitle => 'デジタル広告技術の知識をテストしましょう';

  @override
  String get quizzes => 'クイズ';

  @override
  String get accuracy => '正答率';

  @override
  String get categories => 'カテゴリ';

  @override
  String get yourProgress => 'あなたの進捗';

  @override
  String get averageScore => '平均スコア';

  @override
  String get totalQuestions => '総問題数';

  @override
  String get completedQuizzes => '完了したクイズ';

  @override
  String get quizCategories => 'クイズカテゴリ';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get randomQuiz => 'ランダムクイズ';

  @override
  String get viewProgress => '進捗を表示';

  @override
  String get refreshQuestions => '問題を更新';

  @override
  String get progress => '進捗';

  @override
  String get settings => '設定';

  @override
  String get questions => '問題';

  @override
  String get startQuiz => 'クイズ開始';

  @override
  String get nextQuestion => '次の問題';

  @override
  String get previousQuestion => '前の問題';

  @override
  String get submitAnswer => '回答を送信';

  @override
  String get help => 'ヘルプ';

  @override
  String get correct => '正解！';

  @override
  String get incorrect => '不正解';

  @override
  String get explanation => '説明';

  @override
  String get quizCompleted => 'クイズ完了！';

  @override
  String youScored(Object score, Object total) {
    return '$total問中$score問正解でした';
  }

  @override
  String get viewResults => '結果を表示';

  @override
  String get backToHome => 'ホームに戻る';

  @override
  String get exitQuiz => 'クイズを終了しますか？';

  @override
  String get exitQuizMessage => '本当に終了しますか？進捗が失われます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get exit => '終了';

  @override
  String get finish => '完了';

  @override
  String get next => '次へ';

  @override
  String get loadingQuestions => '問題を読み込み中...';

  @override
  String get generatingQuestions => 'AdTech書籍から問題を生成中...';

  @override
  String get quizReady => 'クイズの準備完了！';

  @override
  String get errorGeneratingQuestions => 'AdTech書籍から問題を生成できませんでした。インターネット接続を確認して再試行してください。';

  @override
  String get errorLoadingQuestions => '問題の読み込みに失敗しました。再試行してください。';

  @override
  String get noQuestionsGenerated => 'このカテゴリの問題を生成できませんでした。ネットワークの問題やAPI制限が原因の可能性があります。アプリは代替問題を使用します。';

  @override
  String get usingFallbackQuestions => '代替問題を使用中';

  @override
  String get tryAgain => 'もう一度挑戦！';

  @override
  String get goBack => '戻る';

  @override
  String get unableToGenerateQuestions => '問題を生成できません';

  @override
  String get score => 'スコア';

  @override
  String get streak => '連続正解';

  @override
  String get listening => '聞き取り中...';

  @override
  String get listeningContinuously => '継続的に聞き取り中...';

  @override
  String get command => 'コマンド';

  @override
  String get language => '言語';

  @override
  String get english => '英語';

  @override
  String get japanese => '日本語';

  @override
  String get theme => 'テーマ';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get system => 'システム';

  @override
  String get questionsPerQuiz => 'クイズあたりの問題数';

  @override
  String get soundEffects => 'サウンドエフェクト';

  @override
  String get hapticFeedback => '触覚フィードバック';

  @override
  String get interactiveMode => 'インタラクティブモード';

  @override
  String get about => 'アプリについて';

  @override
  String get version => 'バージョン';

  @override
  String get description => 'AdTechの概念を学ぶための包括的なクイズアプリ';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get contactUs => 'お問い合わせ';

  @override
  String get rateApp => 'アプリを評価';

  @override
  String get shareApp => 'アプリを共有';

  @override
  String get resetProgress => '進捗をリセット';

  @override
  String get resetProgressMessage => 'すべての進捗をリセットしますか？この操作は取り消せません。';

  @override
  String get reset => 'リセット';

  @override
  String get progressReset => '進捗リセット';

  @override
  String get progressResetMessage => 'すべての進捗が正常にリセットされました。';

  @override
  String get ok => 'OK';

  @override
  String get advertisingBasics => '広告の基礎';

  @override
  String get adtechPlatforms => 'AdTechプラットフォーム';

  @override
  String get targetingAndData => 'ターゲティングとデータ';

  @override
  String get mediaBuying => 'メディア購入';

  @override
  String get userIdentification => 'ユーザー識別';

  @override
  String get adFraudAndPrivacy => '広告詐欺とプライバシー';

  @override
  String get attribution => 'アトリビューション';

  @override
  String get optionA => '選択肢A';

  @override
  String get optionB => '選択肢B';

  @override
  String get optionC => '選択肢C';

  @override
  String get optionD => '選択肢D';

  @override
  String get question => '問題';

  @override
  String get options => '選択肢';

  @override
  String get selectAnswer => '回答を選択';

  @override
  String get yourAnswer => 'あなたの回答';

  @override
  String get correctAnswer => '正解';

  @override
  String get yourScore => 'あなたのスコア';

  @override
  String get totalCorrect => '正解数';

  @override
  String get percentage => 'パーセンテージ';

  @override
  String get timeTaken => '所要時間';

  @override
  String get bestStreak => '最高連続正解';

  @override
  String get currentStreak => '現在の連続正解';

  @override
  String get categoryBreakdown => 'カテゴリ別分析';

  @override
  String get performance => 'パフォーマンス';

  @override
  String get statistics => '統計';

  @override
  String get quizHistory => 'クイズ履歴';

  @override
  String get noQuizzesYet => 'まだクイズを受けていません';

  @override
  String get takeYourFirstQuiz => '最初のクイズを受けて、ここで進捗を確認しましょう！';

  @override
  String get categoryPerformance => 'カテゴリ別パフォーマンス';

  @override
  String get questionsAnswered => '回答した問題数';

  @override
  String get averageAccuracy => '平均正答率';

  @override
  String get completionRate => '完了率';

  @override
  String get notStarted => '未開始';

  @override
  String get inProgress => '進行中';

  @override
  String get completed => '完了';

  @override
  String get excellent => '優秀';

  @override
  String get good => '良好';

  @override
  String get fair => '普通';

  @override
  String get needsImprovement => '改善が必要';

  @override
  String get perfect => '完璧！';

  @override
  String get greatJob => '素晴らしい！';

  @override
  String get keepGoing => '頑張って！';

  @override
  String get almostThere => 'あと少し！';

  @override
  String get noExplanationAvailable => '説明は利用できません。';

  @override
  String get explanationNotAvailable => '説明は利用できません。';

  @override
  String get loading => '読み込み中...';

  @override
  String get refreshing => '更新中';

  @override
  String get generatingNewQuestions => 'AdTech書籍から新しい問題を生成中...';

  @override
  String get noContentFound => 'このカテゴリのコンテンツが見つかりません';

  @override
  String get aiGenerationFailed => 'AI生成に失敗しました';

  @override
  String get usingFallbackQuestionsDueToError => 'エラーのため代替問題を使用中';

  @override
  String get errorGettingQuestions => 'カテゴリの問題取得エラー';

  @override
  String get errorGettingRandomQuestions => 'ランダム問題取得エラー';

  @override
  String get errorValidatingAnswer => '回答検証エラー';

  @override
  String get errorGettingExplanation => '説明取得エラー';

  @override
  String get errorExtractingPdfContent => 'PDFコンテンツ抽出エラー';

  @override
  String get errorCallingOpenaiApi => 'OpenAI API呼び出しエラー';

  @override
  String get openaiApiKeyNotConfigured => 'OpenAI APIキーが設定されていません - 代替問題を使用中';

  @override
  String get authenticationFailed => '認証に失敗しました - APIキーを確認してください';

  @override
  String get rateLimitExceeded => 'レート制限を超過しました';

  @override
  String get failedToExtractJson => 'OpenAIレスポンスからJSONの抽出に失敗しました';

  @override
  String get openaiApiError => 'OpenAI APIエラー';

  @override
  String successfullyGeneratedQuestions(Object count) {
    return 'カテゴリ「$count」の問題を正常に生成しました';
  }

  @override
  String get contentLength => 'コンテンツ長';

  @override
  String get characters => '文字';

  @override
  String get openaiResponseContentLength => 'OpenAIレスポンスコンテンツ長';

  @override
  String get fallingBackToGeneratedQuestions => 'カテゴリの生成問題にフォールバック中';

  @override
  String get errorValidatingWithAi => 'AI検証エラー、フォールバックを使用';

  @override
  String get errorGeneratingAiExplanation => 'AI説明生成エラー';

  @override
  String get errorGettingBookContentForValidation => '検証用の書籍コンテンツ取得エラー';

  @override
  String get errorGettingBookContentForExplanation => '説明用の書籍コンテンツ取得エラー';
}
