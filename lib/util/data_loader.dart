import 'package:any_link_preview/any_link_preview.dart';
import 'package:app/model/learning.dart';
import 'package:app/view/task_alert_page.dart';

class DataLoader {
  static const List<String> quotes = ['Sorge dich gut um deinen Körper',
    'Wer kämpft, kann verlieren',
    'Der härteste Schritt zu Fitness ist der erste',];
  static const List<String> quotesAuthor = ['Jim Rohn', 'Berthold Brecht', 'Heather Montgomery',];

  static int getScoreForTask(int taskType) {
    switch (taskType) {
      case 4:
        return 100;
      case 2:
        return 20;
      case 0:
        return 10;
      case 1:
        return 20;
      case 3:
        return 10;
      default:
        return 0;
    }
  }
}

class FitnessItemInfo {
  late int id;
  late String image;
  late String name;
  late int count;
  late int target;
  late int points;
  late TaskType taskType;

  FitnessItemInfo(this.id, this.image, this.name, this.count, this.target, this.points, this.taskType);

  static List<FitnessItemInfo> generateDummyList() {
    List<FitnessItemInfo> data = List.empty(growable: true);
    data.add(FitnessItemInfo(12920, 'assets/images/water.jpg', 'Wasser', 5, 8, 5, TaskType.water));
    data.add(FitnessItemInfo(12921, 'assets/images/walk.jpg', 'Schritte', 3041, 8156, 1, TaskType.steps));
    data.add(FitnessItemInfo(12923, 'assets/images/exercise.jpg', 'Übungen', 2, 6, 25, TaskType.exercise));
    data.add(FitnessItemInfo(12922, 'assets/images/break.jpg', 'Pausen', 4, 10, 10, TaskType.breaks));
    return data;
  }
}

class LearningMaterialInfo {
  int? id;
  String? thumbnail;
  String? image;
  // TODO: @Justin -- only use the title and description for search
  String? title;
  String? description;
  String? detailsUrl;
  String? videoUrl;
  LearningContent? originalContent;

  LearningMaterialInfo(this.title);

  static Future<LearningMaterialInfo> copyContentFromLink(LearningContent content) async {
    Metadata? metadata = await AnyLinkPreview.getMetadata(
      link: content.contentUri ?? "",
      cache: const Duration(days: 7),
    );
    LearningMaterialInfo info = LearningMaterialInfo(metadata?.title);
    info.thumbnail = metadata?.image;
    info.description = metadata?.desc;
    info.originalContent = content;
    return info;
  }

  static List<LearningMaterialInfo> generateDummyList() {
    List<LearningMaterialInfo> data = List.empty(growable: true);
    // data.add(LearningMaterialInfo(13720, 'assets/images/thumb_posture_error.png', '', 'Wie Sie Ihre Sitzhaltung verbessern können?', 'Watch this video to quickly learn ways to fix your posture', '', 'https://www.youtube.com/watch?v=RqcOCBb4arc'));
    // data.add(LearningMaterialInfo(13721, 'assets/images/thumb_nutir_foods.png', 'assets/images/nutri_food_banner.png', 'Gesunde Ernährung: Ausgewogen und abwechslungsreich', foodDetails, '', ''));
    // data.add(LearningMaterialInfo(13722, 'assets/images/thumb_office_exercises.png', '', 'Bürogymnastik: 9 Übungen für mehr Bewegung im Büro', 'Read details about correct ways for doing quick exercises in your office', 'https://www.gesundheit.de/fitness/fitness-uebungen/buerogymnastik/galerie-buerogymnastik', ''));
    return data;
  }

  static List<LearningMaterialInfo> generateDummyExerciseList() {
    List<LearningMaterialInfo> data = List.empty(growable: true);
    // data.add(LearningMaterialInfo(13720, 'assets/images/thumb_posture_error.png', '', 'Wie Sie Ihre Sitzhaltung verbessern können?', 'Watch this video to quickly learn ways to fix your posture', '', 'https://www.youtube.com/watch?v=RqcOCBb4arc'));
    // data.add(LearningMaterialInfo(13721, 'assets/images/thumb_nutir_foods.png', 'assets/images/nutri_food_banner.png', 'Gesunde Ernährung: Ausgewogen und abwechslungsreich', foodDetails, '', ''));
    // data.add(LearningMaterialInfo(13722, 'assets/images/thumb_office_exercises.png', '', 'Bürogymnastik: 9 Übungen für mehr Bewegung im Büro', 'Read details about correct ways for doing quick exercises in your office', 'https://www.gesundheit.de/fitness/fitness-uebungen/buerogymnastik/galerie-buerogymnastik', ''));
    return data;
  }

  bool? contains(String lowerCase) {}

  void add(List<String> learningMaterialResults) {}
}

class LeaderboardParticipantInfo {
  String? name;
  int? points;

  LeaderboardParticipantInfo(this.name, this.points);

  static List<LeaderboardParticipantInfo> generateDummyList() {
    List<LeaderboardParticipantInfo> data = List.empty(growable: true);
    data.add(LeaderboardParticipantInfo('Don', 158));
    data.add(LeaderboardParticipantInfo('Duel', 177));
    data.add(LeaderboardParticipantInfo('Carrot', 165));
    data.add(LeaderboardParticipantInfo('Vox', 110));
    data.add(LeaderboardParticipantInfo('Again', 85));
    data.add(LeaderboardParticipantInfo('Buch', 105));
    data.add(LeaderboardParticipantInfo('Queen', 141));
    data.add(LeaderboardParticipantInfo('Napoleon', 180));
    return data;
  }
}

String foodDetails =  '<div class="row">\n'+
    '                <header class="col-12 col-lg-9 article-header">\n'+
    '    \n'+
    '    <small class="pointed-brand" aria-hidden="true">\n'+
    '        Gesund leben\n'+
    '    </small>\n'+
    '    <h1 aria-label="Gesund leben: Gesunde Ernährung: Ausgewogen und abwechslungsreich">\n'+
    '        Gesunde Ernährung: Ausgewogen und abwechslungsreich\n'+
    '    </h1>\n'+
    '\n'+
    '    <div class="article-header__buttons">\n'+
    '        <div class="bookmark_controls">\n'+
    '    <button disabled="" id="bookmark_controls__button_add" class="btn btn--article bookmark_controls__add" data-id="893" type="button">\n'+
    '        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="19" viewBox="0 0 498 497" class="icon icon-pin replaced-svg" aria-hidden="true" focusable="false" role="img"><title>Merkzettel</title><path d="M0 497l31.066-12.135 152.417-150.96 107.274 108.244c1.618 1.618 3.398 2.832 5.34 3.64 1.941.81 3.883 1.214 5.824 1.214.648 0 1.295-.08 1.942-.242a7.979 7.979 0 011.942-.243c2.588-.647 4.854-1.942 6.795-3.883a18.867 18.867 0 004.369-6.796c6.796-22.652 9.304-45.79 7.524-69.413-1.78-23.623-7.686-46.275-17.718-67.956l85.917-85.917c6.148 1.942 12.54 3.398 19.173 4.369 6.634.97 13.51 1.456 20.63 1.456 8.414 0 17.151-.647 26.212-1.942 9.06-1.294 18.284-3.398 27.668-6.31 2.589-.97 4.773-2.427 6.553-4.369 1.78-1.941 2.993-4.206 3.64-6.795a15.776 15.776 0 000-7.767c-.647-2.588-1.941-4.854-3.883-6.795L314.057 4.8c-1.942-1.942-4.207-3.317-6.796-4.126-2.589-.809-5.34-.89-8.252-.243-2.589.648-4.854 1.942-6.796 3.884a18.866 18.866 0 00-4.368 6.795c-5.178 17.151-8.09 33.574-8.738 49.269-.647 15.695 1.133 30.661 5.34 44.9-.647.323-1.133.647-1.456.97l-.971.971-83.004 83.005a206.935 206.935 0 00-41.26-14.077 194.331 194.331 0 00-43.2-4.854c-9.061 0-18.041.647-26.94 1.941a172.687 172.687 0 00-25.97 5.825 18.866 18.866 0 00-6.795 4.369c-1.942 1.942-3.236 4.207-3.884 6.796-.647 2.588-.566 5.177.243 7.766.81 2.589 2.184 4.854 4.126 6.796L161.64 312.06 12.62 463.021 0 497z" fill-rule="nonzero"></path></svg>\n'+
    '        Merken\n'+
    '    </button>\n'+
    '    \n'+
    '    <button disabled="" hidden="" id="bookmark_controls__button_remove" class="btn btn--article bookmark_controls__remove" data-id="893" type="button">\n'+
    '        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="19" viewBox="0 0 498 497" class="icon icon-pin replaced-svg" aria-hidden="true" focusable="false" role="img"><title>Merkzettel</title><path d="M0 497l31.066-12.135 152.417-150.96 107.274 108.244c1.618 1.618 3.398 2.832 5.34 3.64 1.941.81 3.883 1.214 5.824 1.214.648 0 1.295-.08 1.942-.242a7.979 7.979 0 011.942-.243c2.588-.647 4.854-1.942 6.795-3.883a18.867 18.867 0 004.369-6.796c6.796-22.652 9.304-45.79 7.524-69.413-1.78-23.623-7.686-46.275-17.718-67.956l85.917-85.917c6.148 1.942 12.54 3.398 19.173 4.369 6.634.97 13.51 1.456 20.63 1.456 8.414 0 17.151-.647 26.212-1.942 9.06-1.294 18.284-3.398 27.668-6.31 2.589-.97 4.773-2.427 6.553-4.369 1.78-1.941 2.993-4.206 3.64-6.795a15.776 15.776 0 000-7.767c-.647-2.588-1.941-4.854-3.883-6.795L314.057 4.8c-1.942-1.942-4.207-3.317-6.796-4.126-2.589-.809-5.34-.89-8.252-.243-2.589.648-4.854 1.942-6.796 3.884a18.866 18.866 0 00-4.368 6.795c-5.178 17.151-8.09 33.574-8.738 49.269-.647 15.695 1.133 30.661 5.34 44.9-.647.323-1.133.647-1.456.97l-.971.971-83.004 83.005a206.935 206.935 0 00-41.26-14.077 194.331 194.331 0 00-43.2-4.854c-9.061 0-18.041.647-26.94 1.941a172.687 172.687 0 00-25.97 5.825 18.866 18.866 0 00-6.795 4.369c-1.942 1.942-3.236 4.207-3.884 6.796-.647 2.588-.566 5.177.243 7.766.81 2.589 2.184 4.854 4.126 6.796L161.64 312.06 12.62 463.021 0 497z" fill-rule="nonzero"></path></svg>\n'+
    '        Gemerkt\n'+
    '    </button>\n'+
    '</div>\n'+
    '        <div id="readspeaker_button1" class="rs_skip rsbtn rs_preserve" style="display: none;">\n'+
    '    \n'+
    '\n'+
    '    \n'+
    '            \n'+
    '        \n'+
    '\n'+
    '    <a rel="nofollow" class="rsbtn_play" accesskey="L" title="Um den Text anzuhören, verwenden Sie bitte ReadSpeaker webReader" href="//app-eu.readspeaker.com/cgi-bin/rsent?customerid=11471&amp;lang=de_de&amp;readid=readspeaker_content&amp;url=https%3A%2F%2Fgesund.bund.de%2Fgesunde-ernaehrung">        \n'+
    '\n'+
    '        \n'+
    '        <span class="rsbtn_left rsimg rspart">\n'+
    '            <span class="rsbtn_text">\n'+
    '                <span>Vorlesen</span>\n'+
    '            </span>\n'+
    '        </span>\n'+
    '        <span class="rsbtn_right rsimg rsplay rspart"></span>\n'+
    '    </a>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '<div class="rs-placeholder">\n'+
    '    <button class="rs-placeholder__btn btn btn--article" title="Um den Text anzuhören, verwenden Sie bitte ReadSpeaker webReader" disabled="disabled">\n'+
    '        <span class="rs-placeholder__left"></span>\n'+
    '        <span class="rs-placeholder__text">Vorlesen</span>\n'+
    '        <span class="rs-placeholder__right"></span>\n'+
    '    </button>\n'+
    '</div>\n'+
    '        <p class="article-header__alert-text">\n'+
    '            Diese Funktionen benötigen Cookies.\n'+
    '            <a href="/datenschutz#cookies" title="Zu den Einstellungen">\n'+
    '                Zu den Einstellungen\n'+
    '            </a>\n'+
    '        </p>\n'+
    '    </div>\n'+
    '    \n'+
    '</header>\n'+
    '\n'+
    '                \n'+
    '\n'+
    '<div class="col-md-3 side-navigation">\n'+
    '    <nav aria-label="Seitennavigation">\n'+
    '        <ul class="side-navigation__list">\n'+
    '            <li class="side-navigation__list-title">\n'+
    '                <h2>Inhalt</h2>\n'+
    '            </li>\n'+
    '            \n'+
    '                <li><a href="#auf-einen-blick" class="side-navigation__list-item">\n'+
    '                    Auf einen Blick\n'+
    '                </a></li>\n'+
    '            \n'+
    '            \n'+
    '\n'+
    '                <li><a href="#einleitung" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Einleitung\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#10-regeln" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            10 Regeln\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#obst-und-gemuese" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Obst und Gemüse\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#volles-korn" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Volles Korn\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#salz-und-zucker" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Salz und Zucker\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#tierische-lebensmittel" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Tierische Lebensmittel\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#vegetarisch-und-vegan" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Vegetarisch und vegan\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                <li><a href="#einkauf-und-zubereitung" class="side-navigation__list-item">\n'+
    '                    \n'+
    '                            Einkauf und Zubereitung\n'+
    '                        \n'+
    '                    </a>\n'+
    '                </li>\n'+
    '\n'+
    '            \n'+
    '            \n'+
    '                <li><a href="#quellen" class="side-navigation__list-item">\n'+
    '                    Quellen\n'+
    '                </a></li>\n'+
    '            \n'+
    '        </ul>\n'+
    '    </nav>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                \n'+
    '                        \n'+
    '                <div id="readspeaker_content">\n'+
    '                    <section class="col-12 col-lg-8 article-introduction">\n'+
    '    <div class="article-offset">\n'+
    '        <p>Eine gesunde Ernährung kann die Gesundheit positiv beeinflussen und vielen Krankheiten vorbeugen. Eine ausgewogene und abwechslungsreiche Auswahl von Lebensmitteln trägt dazu bei. Ein gesunder Speiseplan enthält viel Obst, Gemüse und Vollkornprodukte, aber nur wenig Salz und Zucker.&nbsp;</p>\n'+
    '    </div>\n'+
    '</section>\n'+
    '\n'+
    '                    \n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="auf-einen-blick" class="col-12 col-lg-9 summary">\n'+
    '        <div class="summary__wrapper">\n'+
    '\n'+
    '            <h2>Auf einen Blick</h2>\n'+
    '\n'+
    '            <div class="summary__list">\n'+
    '                <ul><li>Abwechslungsreich zu essen ist eine wesentliche Säule gesunder Ernährung.</li><li>Obst, Gemüse, Vollkorn- und Milchprodukte gehören zu den wichtigsten Bestandteilen einer vollwertigen Mischkost.</li><li>Salz und Zucker sind bei einer gesunden Ernährung nicht verboten, sollten aber in Maßen genossen werden.</li><li>Wer Fleisch, Fisch und Milchprodukte nicht auf seinem Speiseplan hat, muss darauf achten, den Bedarf an bestimmten Nährstoffen wie Eisen oder Kalzium gezielt mit pflanzlichen Lebensmitteln zu decken.</li><li>Indem man bewusst einkauft, viel selbst kocht und dabei auf eine schonende Zubereitung achtet, trägt man schon viel zu einer gesunden Ernährung bei.</li></ul>\n'+
    '            </div>\n'+
    '\n'+
    '            \n'+
    '                <p class="summary__note">\n'+
    '                    \n'+
    '                        <strong>Hinweis:</strong> Die Informationen dieses Artikels können und sollen einen Arztbesuch nicht ersetzen und dürfen nicht zur Selbstdiagnostik oder -behandlung verwendet werden.\n'+
    '                    \n'+
    '                </p>\n'+
    '            \n'+
    '\n'+
    '        </div>\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    <section id="content-image" class="col-12 col-lg-9 article-images">\n'+
    '                        \n'+
    '                            \n'+
    '\n'+
    '    <picture>\n'+
    '        <source media="(min-width: 768px)" srcset="https://gesund.bund.de/assets/medium/gesund_durch_ernaehrung_01.jpg">\n'+
    '        <source media="(min-width: 300px)" srcset="https://gesund.bund.de/assets/small/gesund_durch_ernaehrung_01.jpg">\n'+
    '        <img class="rs_skip article-images__hero" src="https://gesund.bund.de/assets/large/gesund_durch_ernaehrung_01.jpg" loading="lazy" alt="Bunter Salat mit Linsen" title="Gesunde Ernährung (Quelle: Getty Images/PamelaJoeMcFarlane)" width="920" height="520">\n'+
    '    </picture>\n'+
    '\n'+
    '\n'+
    '                        \n'+
    '\n'+
    '\n'+
    '                        \n'+
    '\n'+
    '                    </section>\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="einleitung" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Einleitung" data-title-desktop="Warum ist eine gesunde Ernährung wichtig?">\n'+
    '            Warum ist eine gesunde Ernährung wichtig?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Nahrungsaufnahme ist ein Grundbedürfnis, um das Überleben zu sichern. Essen und Trinken sind aber auch ein wichtiger kultureller und sozialer Bestandteil des Lebens und tragen wesentlich zum Wohlbefinden bei. Eine gesunde Ernährung kann außerdem dafür sorgen, dass man leistungsfähiger ist, seltener krank wird und ein zufriedeneres Leben führt.</p><p>Die Grundlage dafür ist eine sinnvolle und vor allem abwechslungsreiche Auswahl der Lebensmittel, die man täglich zu sich nimmt. Darüber hinaus sollte man die Lebensmittel schonend und fettarm zubereiten und Mahlzeiten bewusst genießen – befreit von der Hektik des Alltags. Denn achtsames, genussvolles Essen ist gesundes Essen: Es fördert den Genuss und das Sättigungsempfinden. Das kann auch beim Abnehmen helfen.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '                \n'+
    '<figure class="article-images__figure">\n'+
    '    \n'+
    '            <picture>\n'+
    '                <source media="(min-width: 768px)" srcset="https://gesund.bund.de/assets/large/gesund_durch_ernaehrung_02.jpg">\n'+
    '                <source media="(min-width: 300px)" srcset="https://gesund.bund.de/assets/medium/gesund_durch_ernaehrung_02.jpg">\n'+
    '                <img class="rs_skip article-offset default" src="https://gesund.bund.de/assets/small/gesund_durch_ernaehrung_02.jpg" alt="Ein junger Mann isst einen Salat." title="Gesunde Ernährung (Quelle: Getty Images/Ross Helen)" loading="lazy" width="700" height="400">\n'+
    '            </picture>\n'+
    '        \n'+
    '\n'+
    '    \n'+
    '\n'+
    '</figure>\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="10-regeln" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="10 Regeln" data-title-desktop="Wie sieht eine gesunde Ernährung aus?">\n'+
    '            Wie sieht eine gesunde Ernährung aus?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Es ist nicht immer leicht, sich ausgewogen zu ernähren, denn die Auswahl an schnell verfügbaren Snacks, Fertiggerichten, Fast Food und Essen zum Mitnehmen ist riesig. Oft greift man auf solche Angebote zurück und vergisst, dass ein frisches, gesundes Essen gar nicht so viel Arbeit macht. Ein leichter Salat oder ein Nudelgericht mit Gemüse beispielsweise sind innerhalb kurzer Zeit zubereitet. Außerdem gibt es viele Möglichkeiten, unterwegs schnelle und gesunde Snacks zu essen.</p><p>Eine Orientierung zur gesunden Ernährung bieten die 10 Regeln der Deutschen Gesellschaft für Ernährung (DGE):</p><p><strong>1. Lebensmittelvielfalt genießen</strong></p><p>Je abwechslungsreicher, desto besser und gesünder. Dabei mehr pflanzliche als tierische Nahrungsmittel essen.</p><p><strong>2. Gemüse und Obst: 5 am Tag</strong></p><p>2 Portionen Obst und 3 Portionen Gemüse versorgen den Körper mit wichtigen Vitaminen und weiteren wertvollen Mineralstoffen.</p><p><strong>3. Vollkorn wählen</strong></p><p>Getreideprodukte wie Nudeln und Brot aus vollem Korn enthalten viel mehr Nährstoffe als Produkte aus weißem Mehl – und machen zudem deutlich länger satt. </p><p><strong>4. Mit tierischen Lebensmitteln die Auswahl ergänzen</strong></p><p>Milch und Milchprodukte können täglich verzehrt werden, Fisch ein- bis zweimal pro Woche. Für Fleisch wird empfohlen, sich auf 300 bis 600 Gramm pro Woche zu beschränken.</p><p><strong>5. Gesundheitsfördernde Fette nutzen</strong></p><p>Pflanzliche Öle wie Rapsöl enthalten gesundheitsfördernde Fettsäuren und sollten gegenüber tierischen Fetten bevorzugt werden.&nbsp;</p><p><strong>6. Zucker und Salz einsparen</strong></p><p><a href="/zucker">Zucker</a> enthält unnötig viele Kalorien und erhöht das <a href="/karies">Kariesrisiko</a>. Zu viel Salz kann den <a href="/bluthochdruck">Blutdruck erhöhen</a>, mehr als 6 Gramm am Tag (etwa ein Teelöffel) sind nicht gesund.&nbsp;</p><p><strong>7. Am besten Wasser trinken</strong></p><p>Wer mindestens 1,5 Liter Wasser oder andere kalorienfreie Getränke am Tag trinkt, versorgt den Körper gut mit Flüssigkeit. Auf zuckergesüßte und alkoholische Getränke besser verzichten, denn sie sind kalorienreich, fördern die <a href="/uebergewicht">Gewichtszunahme</a> und können die Entstehung bestimmter Erkrankungen begünstigen.</p><p><strong>8. Mahlzeiten schonend zubereiten</strong></p><p>Kurz und mit wenig Wasser sowie wenig Fett gegarte Lebensmittel enthalten mehr Nährstoffe und der natürliche Geschmack bleibt erhalten. Beim starken Anbraten oder gar Anbrennen entstehen <a href="/unerwuenschte-inhaltsstoffe-in-lebensmitteln">gesundheitsschädliche Stoffe</a>.</p><p><strong>9. Achtsam essen und genießen</strong></p><p>Langsames, bewusstes Essen fördert den Genuss und das Sättigungsempfinden.</p><p><strong>10. Auf das Gewicht achten und in Bewegung bleiben</strong></p><p>Vollwertige Ernährung und körperliche Aktivität sind ein gutes Duo für die Gesundheit. 30 bis 60 Minuten <a href="/gesund-durch-bewegung">Bewegung</a> pro Tag werden für Erwachsene empfohlen, zum Beispiel Rad fahren oder zu Fuß gehen.</p><p class="box grey-light additional-note">Eine grafische Übersicht zu den Ernährungsempfehlungen bieten die <a href="https://www.dge.de/ernaehrungspraxis/vollwertige-ernaehrung/lebensmittelpyramide/" target="_blank" rel="noopener">Lebensmittelpyramide</a> und der <a href="https://www.dge.de/ernaehrungspraxis/vollwertige-ernaehrung/ernaehrungskreis/" target="_blank" rel="noopener">Ernährungskreis</a> der Deutschen Gesellschaft für Ernährung (DGE).</p><p>Der Speiseplan für einen gesunden Tag könnte so aussehen: 1,5 bis 2 Liter über den Tag verteilt Wasser trinken – bei körperlicher Anstrengung entsprechend mehr. Morgens ein Vollkornmüsli mit Früchten genießen und bei den Zwischenmahlzeiten auf Gemüse, Obst, Joghurt oder ein Käse-Roggenbrot zurückgreifen. Entweder mittags oder abends eine warme Mahlzeit mit buntem, frisch zubereitetem Gemüse – entweder mit Vollkornnudeln, Kartoffeln oder Reis.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '                \n'+
    '<figure class="article-images__figure">\n'+
    '    \n'+
    '            <picture>\n'+
    '                <source media="(max-width: 576px)" srcset="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-5-mobil-1.svg">\n'+
    '                <source media="(min-width: 577px)" srcset="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-6.svg">\n'+
    '                <img class="rs_skip article-offset svg" src="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-6.svg" alt="Zu einer gesunden Ernährung gehören 1,5 bis 2 Liter Flüssigkeit am Tag, ein ausgewogenes Frühstück und kleinere Zwischenmahlzeiten. Mittags oder abends sollte man gesunde und abwechslungsreiche essen, am besten pflanzliche Nahrungsmittel." title="Gesunde Ernährung Faktoren" loading="lazy" width="800" height="300">\n'+
    '            </picture>\n'+
    '        \n'+
    '\n'+
    '    \n'+
    '\n'+
    '</figure>\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <div class="box icon-box icon-light-bulb"><img src="/typo3conf/ext/sitepackage/Resources/Public/Icons/icon-box-light-bulb.svg" alt="Hinweis"><p><strong>Wichtig zu wissen: </strong>Zusätzlich ist es wichtig, beim Thema Ernährung immer auch auf den eigenen Körper hören. Dabei helfen Fragen wie: Was tut mir gut, was vertrage ich besser oder schlechter, nach welchem Essen fühle ich mich träge oder energiegeladen?</p></div>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="obst-und-gemuese" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Obst und Gemüse" data-title-desktop="Wie viel Obst und Gemüse gehören auf einen gesunden Speiseplan?">\n'+
    '            Wie viel Obst und Gemüse gehören auf einen gesunden Speiseplan?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Frisches Obst und Gemüse nehmen einen besonderen Platz in der Ernährung ein. Hier hilft eine Faustregel: 5 Portionen Obst und Gemüse am Tag versorgen den Körper mit wichtigen Mikronährstoffen – mit Vitaminen, Mineralien, Ballaststoffen sowie Antioxidantien. Obst und Gemüse können dabei helfen, bestimmten Erkrankungen vorzubeugen, insbesondere Herz-Kreislauf-Erkrankungen wie <a href="/bluthochdruck">Bluthochdruck</a>, <a href="/schlaganfall">Schlaganfall</a> und der <a href="/koronare-herzkrankheit">koronaren Herzkrankheit</a>. Als Messwert für eine Portion gilt eine Handvoll, also zum Beispiel: ein Apfel oder eine Banane, eine Handvoll gedünstetes Gemüse oder frische Beeren.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '                \n'+
    '<figure class="article-images__figure">\n'+
    '    \n'+
    '            <picture>\n'+
    '                <source media="(max-width: 576px)" srcset="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-2-mobil.svg">\n'+
    '                <source media="(min-width: 577px)" srcset="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-2.svg">\n'+
    '                <img class="rs_skip article-full-width svg" src="https://gesund.bund.de/assets/gesund001-gesunde-ernaehrung-abschnitt-2.svg" alt="5 Portionen Obst und Gemüse am Tag versorgen den Körper mit Vitaminen, Mineralien, Ballaststoffen &amp; Antioxidantien." title="Frische und abwechslungsreiche Ernährung" loading="lazy" width="800" height="300">\n'+
    '            </picture>\n'+
    '        \n'+
    '\n'+
    '    \n'+
    '\n'+
    '</figure>\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Vor allem Gemüse kommt am besten täglich auf den Teller. Grünkohl, Rosenkohl und Spinat liefern beispielsweise viel Provitamin A, Vitamin E, Vitamin K, Vitamin B2, Vitamin C, Folsäure, Kalzium, Kalium, Phosphor und Eisen. Hülsenfrüchte, zum Beispiel Linsen und Bohnen, sind ebenfalls eine gute Wahl. Sie liefern wichtige Mineralstoffe wie Kalium, Magnesium und Eisen sowie viele B-Vitamine.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="volles-korn" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Volles Korn" data-title-desktop="Warum lieber Vollkorn statt Weißmehl wählen?">\n'+
    '            Warum lieber Vollkorn statt Weißmehl wählen?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Im Rahmen einer vollwertigen Ernährung ist es wichtig, Produkte aus Weißmehl eher zu vermeiden und Vollkornprodukte vorzuziehen.</p><p>Zum einen liefern Weißmehlprodukte weniger Nährstoffe als Vollkornprodukte.&nbsp;Zum anderen enthält weißes Mehl im Gegensatz zu Vollkornmehl kaum Ballaststoffe. Dadurch werden Lebensmittel aus weißem Mehl schneller verdaut und bleiben kürzer im Darm. Das Sättigungsgefühl hält daher bei Weißmehlprodukten nicht so lange an wie bei Lebensmitteln aus Vollkorn.</p><p>Die Ballaststoffe aus Vollkornmehl tragen außerdem dazu bei, Krankheiten wie <a href="/diabetes-typ-2">Typ-2-Diabetes</a>, <a href="/darmkrebs">Dickdarmkrebs</a>, Fettstoffwechselstörungen und Herz-Kreislauf-Erkrankungen vorzubeugen.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            \n'+
    '\n'+
    '    <div class="article-video-box article-full-width">\n'+
    '        <div class="article-video-box__inner article-offset">\n'+
    '            <small class="pointed-brand" aria-hidden="true">\n'+
    '                Video\n'+
    '            </small>\n'+
    '            <h3>Was ist Diabetes Typ 2?</h3>\n'+
    '            \n'+
    '            <p class="article-video-box__description">Das folgende Video berichtet über mögliche Symptome, Ursachen und Behandlungsmethoden bei einer Diabetes-Typ-2-Erkrankung. </p>\n'+
    '            \n'+
    '            <span class="mejs__offscreen">Video-Player</span><div id="mep_0" class="mejs__container mejs__container-keyboard-inactive video-player article mejs__video" tabindex="0" role="application" aria-label="Video-Player" style="width: 715px; height: 402.188px; min-width: 249px;"><div class="mejs__inner"><div class="mejs__mediaelement"><mediaelementwrapper id="mejs_0811712922596961"><video class="video-player article" preload="metadata" width="640" height="360" style="max-width: 100%; height: 402.188px; width: 715px;" poster="https://gesund.bund.de/assets/medium/vorschaubild_diabetes-typ-2.jpg" playsinline="" webkit-playsinline="" crossorigin="anonymous" data-video-title="Was ist Diabetes Typ 2?" id="mejs_0811712922596961_html5" src="https://gesund.bund.de/assets/011_diabetes-typ2_finaleaudio-2.mp4">\n'+
    '                <source type="video/mp4" src="https://gesund.bund.de/assets/011_diabetes-typ2_finaleaudio-2.mp4">\n'+
    '                <source type="video/webm" src="https://gesund.bund.de/assets/011_diabetes-typ2_finaleaudio-2.webm">\n'+
    '                <source type="video/ogg" src="">\n'+
    '\n'+
    '                \n'+
    '                        <track default="" srclang="de" kind="captions" src="https://gesund.bund.de/assets/_ut_wasistdiabetes-typ-2.vtt">\n'+
    '                    \n'+
    '            </video></mediaelementwrapper></div><div class="mejs__layers"><div class="mejs__captions-layer mejs__layer" style="display: none; width: 100%; height: 100%;"><div class="mejs__captions-position mejs__captions-position-hover"><span class="mejs__captions-text"></span></div></div><div class="mejs__poster mejs__layer" style="background-image: url(&quot;https://gesund.bund.de/assets/medium/vorschaubild_diabetes-typ-2.jpg&quot;); width: 100%; height: 100%;"><img class="mejs__poster-img" width="0" height="0" src="https://gesund.bund.de/assets/medium/vorschaubild_diabetes-typ-2.jpg"></div><div class="mejs__overlay mejs__layer" style="width: 100%; height: 100%; display: none;"><div class="mejs__overlay-loading"><span class="mejs__overlay-loading-bg-img"></span></div></div><div class="mejs__overlay mejs__layer" style="display: none; width: 100%; height: 100%;"><div class="mejs__overlay-error"></div></div><div class="mejs__overlay mejs__layer mejs__overlay-play" style="width: 100%; height: 100%;"><div class="mejs__overlay-button" role="button" tabindex="0" aria-label="Abspielen" aria-pressed="false"></div></div></div><div class="mejs__controls"><div class="mejs__button mejs__playpause-button mejs__play"><button type="button" aria-controls="mep_0" title="Abspielen" aria-label="Abspielen" tabindex="0"></button></div><div class="mejs__time mejs__currenttime-container" role="timer" aria-live="off"><span class="mejs__currenttime">00:00</span></div><div class="mejs__time-rail"><span class="mejs__time-total mejs__time-slider" role="slider" tabindex="0" aria-label="Zeitschieberegler" aria-valuemin="0" aria-valuemax="0" aria-valuenow="0" aria-valuetext="00:00"><span class="mejs__time-buffering" style="display: none;"></span><span class="mejs__time-loaded"></span><span class="mejs__time-current" style="transform: scaleX(0);"></span><span class="mejs__time-hovered no-hover"></span><span class="mejs__time-handle" style="transform: translateX(0px);"><span class="mejs__time-handle-content"></span></span><span class="mejs__time-float"><span class="mejs__time-float-current">00:00</span><span class="mejs__time-float-corner"></span></span></span></div><div class="mejs__time mejs__duration-container"><span class="mejs__duration">05:20</span></div><div class="mejs__button mejs__captions-button"><button type="button" aria-controls="mep_0" title="Untertitel" aria-label="Untertitel" tabindex="0"></button><div class="mejs__captions-selector mejs__offscreen"><ul class="mejs__captions-selector-list"><li class="mejs__captions-selector-list-item"><input type="radio" class="mejs__captions-selector-input" name="mep_0_captions" id="mep_0_captions_none" value="none" checked=""><label class="mejs__captions-selector-label mejs__captions-selected" for="mep_0_captions_none">Keine</label></li><li class="mejs__captions-selector-list-item"><input type="radio" class="mejs__captions-selector-input" name="mep_0_captions" id="mep_0_track_0_captions_de" value="mep_0_track_0_captions_de"><label class="mejs__captions-selector-label" for="mep_0_track_0_captions_de">Deutsch</label></li></ul></div></div><div class="mejs__button mejs__volume-button mejs__mute"><button type="button" aria-controls="mep_0" title="Stummschalten" aria-label="Stummschalten" tabindex="0"></button><a href="javascript:void(0);" class="mejs__volume-slider" aria-label="Lautstärkeregler" aria-valuemin="0" aria-valuemax="100" role="slider" aria-orientation="vertical" aria-valuenow="80" aria-valuetext="80%"><span class="mejs__offscreen">Verwende die Pfeiltaste nach oben/nach unten um die Lautstärke zu erhöhen oder zu verringern.</span><div class="mejs__volume-total"><div class="mejs__volume-current" style="bottom: 0px; height: 80%;"></div><div class="mejs__volume-handle" style="bottom: 80%; margin-bottom: -6px;"></div></div></a></div><div class="mejs__button mejs__fullscreen-button"><button type="button" aria-controls="mep_0" title="Vollbild" aria-label="Vollbild" tabindex="0"></button></div></div></div></div>\n'+
    '            \n'+
    '            <p>Dieses und weitere Videos gibt es auch auf YouTube</p>\n'+
    '            <a href="https://www.youtube.com/watch?v=5Mw08kbQ7qs" title="Youtube: Was ist Diabetes Typ 2?" target="_blank" rel="noopener noreferrer" class="link-arrow">Jetzt ansehen</a>\n'+
    '            <p class="article-video-box__disclaimer">Es gelten die dort bekanntgegebenen Datenschutzhinweise.</p>\n'+
    '        </div>\n'+
    '\n'+
    '    </div>\n'+
    '\n'+
    '\n'+
    '\n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="salz-und-zucker" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Salz und Zucker" data-title-desktop="Warum sollte man mit Zucker und Salz sparsam umgehen?">\n'+
    '            Warum sollte man mit Zucker und Salz sparsam umgehen?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Zucker und Salz sind für die Funktion des menschlichen Körpers unentbehrlich. <a href="/zucker">Zucker</a> liefert dem Körper schnelle Energie. Wenn das Gehirn oder die Muskeln schnell Energie benötigen, stellen Einfachzucker wie Glukose diese besonders zügig bereit. Auch die roten Blutkörperchen und Teile der Nieren sind auf Glukose als Energiequelle angewiesen.</p><p>Salz besteht aus den Mineralstoffen Natrium und Chlorid, die der Körper unter anderem für die Regulation des Blutdrucks und die Aufrechterhaltung des Flüssigkeitshaushalts der Zellen benötigt.</p><p>Aber zu große Mengen an Zucker und Salz können sich negativ auf die Gesundheit auswirken: Ein übermäßiger Zuckerkonsum geht häufig mit <a href="/karies">Karies</a>, <a href="/uebergewicht">Übergewicht</a>, <a href="/uebergewicht-adipositas">Adipositas</a> und ernährungsbedingten Erkrankungen wie <a href="/diabetes-typ-2">Typ-2-Diabetes</a>&nbsp;einher. Zu viel Salz kann den <a href="/bluthochdruck">Blutdruck ansteigen</a> lassen und dadurch <a href="/themen/herz-und-kreislauf">Herz-Kreislauf-Erkrankungen</a> fördern.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            \n'+
    '\n'+
    '    <div class="article-video-box article-full-width">\n'+
    '        <div class="article-video-box__inner article-offset">\n'+
    '            <small class="pointed-brand" aria-hidden="true">\n'+
    '                Video\n'+
    '            </small>\n'+
    '            <h3>Warum ist Bluthochdruck gefährlich?</h3>\n'+
    '            \n'+
    '            <p class="article-video-box__description">Im folgenden Video erfahren Sie, was im Körper bei Bluthochdruck passiert. Welche Folgeschäden können durch Bluthochdruck entstehen und wie kann ein hoher Blutdruck gesenkt werden?</p>\n'+
    '            \n'+
    '            <span class="mejs__offscreen">Video-Player</span><div id="mep_1" class="mejs__container mejs__container-keyboard-inactive video-player article mejs__video" tabindex="0" role="application" aria-label="Video-Player" style="width: 715px; height: 402.188px; min-width: 249px;"><div class="mejs__inner"><div class="mejs__mediaelement"><mediaelementwrapper id="mejs_6514522476964666"><video class="video-player article" preload="metadata" width="640" height="360" style="max-width: 100%; height: 402.188px; width: 715px;" poster="https://gesund.bund.de/assets/medium/vorschaubild-bluthochdruck.jpg" playsinline="" webkit-playsinline="" crossorigin="anonymous" data-video-title="Warum ist Bluthochdruck gefährlich?" id="mejs_6514522476964666_html5" src="https://gesund.bund.de/assets/009-warumistbluthochdruckgefaehrlich_final.mp4">\n'+
    '                <source type="video/mp4" src="https://gesund.bund.de/assets/009-warumistbluthochdruckgefaehrlich_final.mp4">\n'+
    '                <source type="video/webm" src="https://gesund.bund.de/assets/009-warumistbluthochdruckgefaehrlich_final.webm">\n'+
    '                <source type="video/ogg" src="">\n'+
    '\n'+
    '                \n'+
    '                        <track default="" srclang="de" kind="captions" src="https://gesund.bund.de/assets/009_ut_bluthochdruck.vtt">\n'+
    '                    \n'+
    '            </video></mediaelementwrapper></div><div class="mejs__layers"><div class="mejs__captions-layer mejs__layer" style="display: none; width: 100%; height: 100%;"><div class="mejs__captions-position mejs__captions-position-hover"><span class="mejs__captions-text"></span></div></div><div class="mejs__poster mejs__layer" style="background-image: url(&quot;https://gesund.bund.de/assets/medium/vorschaubild-bluthochdruck.jpg&quot;); width: 100%; height: 100%;"><img class="mejs__poster-img" width="0" height="0" src="https://gesund.bund.de/assets/medium/vorschaubild-bluthochdruck.jpg"></div><div class="mejs__overlay mejs__layer" style="width: 100%; height: 100%; display: none;"><div class="mejs__overlay-loading"><span class="mejs__overlay-loading-bg-img"></span></div></div><div class="mejs__overlay mejs__layer" style="display: none; width: 100%; height: 100%;"><div class="mejs__overlay-error"></div></div><div class="mejs__overlay mejs__layer mejs__overlay-play" style="width: 100%; height: 100%;"><div class="mejs__overlay-button" role="button" tabindex="0" aria-label="Abspielen" aria-pressed="false"></div></div></div><div class="mejs__controls"><div class="mejs__button mejs__playpause-button mejs__play"><button type="button" aria-controls="mep_1" title="Abspielen" aria-label="Abspielen" tabindex="0"></button></div><div class="mejs__time mejs__currenttime-container" role="timer" aria-live="off"><span class="mejs__currenttime">00:00</span></div><div class="mejs__time-rail"><span class="mejs__time-total mejs__time-slider" role="slider" tabindex="0" aria-label="Zeitschieberegler" aria-valuemin="0" aria-valuemax="0" aria-valuenow="0" aria-valuetext="00:00"><span class="mejs__time-buffering" style="display: none;"></span><span class="mejs__time-loaded"></span><span class="mejs__time-current" style="transform: scaleX(0);"></span><span class="mejs__time-hovered no-hover"></span><span class="mejs__time-handle" style="transform: translateX(0px);"><span class="mejs__time-handle-content"></span></span><span class="mejs__time-float"><span class="mejs__time-float-current">00:00</span><span class="mejs__time-float-corner"></span></span></span></div><div class="mejs__time mejs__duration-container"><span class="mejs__duration">02:59</span></div><div class="mejs__button mejs__captions-button"><button type="button" aria-controls="mep_1" title="Untertitel" aria-label="Untertitel" tabindex="0"></button><div class="mejs__captions-selector mejs__offscreen"><ul class="mejs__captions-selector-list"><li class="mejs__captions-selector-list-item"><input type="radio" class="mejs__captions-selector-input" name="mep_1_captions" id="mep_1_captions_none" value="none" checked=""><label class="mejs__captions-selector-label mejs__captions-selected" for="mep_1_captions_none">Keine</label></li><li class="mejs__captions-selector-list-item"><input type="radio" class="mejs__captions-selector-input" name="mep_1_captions" id="mep_1_track_0_captions_de" value="mep_1_track_0_captions_de"><label class="mejs__captions-selector-label" for="mep_1_track_0_captions_de">Deutsch</label></li></ul></div></div><div class="mejs__button mejs__volume-button mejs__mute"><button type="button" aria-controls="mep_1" title="Stummschalten" aria-label="Stummschalten" tabindex="0"></button><a href="javascript:void(0);" class="mejs__volume-slider" aria-label="Lautstärkeregler" aria-valuemin="0" aria-valuemax="100" role="slider" aria-orientation="vertical" aria-valuenow="80" aria-valuetext="80%"><span class="mejs__offscreen">Verwende die Pfeiltaste nach oben/nach unten um die Lautstärke zu erhöhen oder zu verringern.</span><div class="mejs__volume-total"><div class="mejs__volume-current" style="bottom: 0px; height: 80%;"></div><div class="mejs__volume-handle" style="bottom: 80%; margin-bottom: -6px;"></div></div></a></div><div class="mejs__button mejs__fullscreen-button"><button type="button" aria-controls="mep_1" title="Vollbild" aria-label="Vollbild" tabindex="0"></button></div></div></div></div>\n'+
    '            \n'+
    '            <p>Dieses und weitere Videos gibt es auch auf YouTube</p>\n'+
    '            <a href="https://www.youtube.com/watch?v=xlhSnd1z50Y&amp;t" title="Youtube: Warum ist Bluthochdruck gefährlich?" target="_blank" rel="noopener noreferrer" class="link-arrow">Jetzt ansehen</a>\n'+
    '            <p class="article-video-box__disclaimer">Es gelten die dort bekanntgegebenen Datenschutzhinweise.</p>\n'+
    '        </div>\n'+
    '\n'+
    '    </div>\n'+
    '\n'+
    '\n'+
    '\n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <h3>Zucker und Salz reduzieren</h3><p>Expertinnen und Experten empfehlen, dass Zucker nicht mehr als 10 Prozent der täglichen Gesamtenergiezufuhr ausmachen sollte. Dazu zählt auch der Zucker, der bereits in Fertigprodukten, Honig und Fruchtsäften enthalten ist. Indem man auf stark verarbeitete und zuckergesüßte Lebensmittel und Getränke weitestgehend verzichtet, kann man die Zuckeraufnahme deutlich verringern.</p><p>Dasselbe gilt für Salz: Da verarbeitete Lebensmittel oft viel verstecktes Salz enthalten, ist es besser, frische und unverarbeitete Lebensmittel zu essen und selbst zu kochen: Dabei kann man Salz auch zum Teil durch Gewürze und Kräuter ersetzen. Insgesamt sollte ein erwachsener Mensch maximal 6 Gramm Salz pro Tag aufnehmen, das entspricht etwa einem Teelöffel. Wenn man Salz verwendet, ist dieses vorzugsweise mit den lebenswichtigen Spurenelementen Jod und Fluorid angereichert. Jod ist wichtig für die Funktion der Schilddrüse und für viele Stoffwechselvorhänge im Körper. Fluorid wird für die Stärkung des Zahnschmelzes und somit zum <a href="/zahnvorsorge-mundhygiene">Schutz vor Karies</a> benötigt.</p><div class="box icon-box icon-magnifying-glass"><img src="/typo3conf/ext/sitepackage/Resources/Public/Icons/icon-magnifying-glass.svg" alt="Hinweis"><p><strong>Interessant zu wissen:</strong> Der Körper gewöhnt sich an den Geschmack von Salz und Zucker und kann sich auch langsam wieder entwöhnen. Daher ist es sinnvoll, die Zucker- und Salzzufuhr in kleinen Mengen zu verringern – so fällt die Gewöhnung leichter. Wenn man Kinder erst gar&nbsp; nicht an eine hohe Zufuhr von Zucker und Salz gewöhnt, dann entsteht in der Regel auch kein Verlangen danach.</p></div>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="tierische-lebensmittel" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Tierische Lebensmittel" data-title-desktop="Wie lauten die Empfehlungen für tierische Lebensmittel?">\n'+
    '            Wie lauten die Empfehlungen für tierische Lebensmittel?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <h3>Milch, Milchprodukte und Eier</h3><p>Milch und Milchprodukte wie Käse und Joghurt kann man ohne Bedenken täglich verzehren. Sie liefern hochwertiges Eiweiß und wichtige Mineralstoffe wie Kalzium und B-Vitamine. Auch Eier enthalten Eiweiß, Vitamine und Mineralstoffe und können regelmäßig verzehrt werden. Da aber vor allem Eigelb neben den vielen gesundheitsförderlichen Inhaltsstoffen aber auch einen hohen Gehalt an tierischen Fetten und Cholesterin aufweist, rät die Deutsche Gesellschaft für Ernährung (DGE) von einem übermäßigen Verzehr ab.</p><div class="box icon-box icon-thumbs-up"><img src="/typo3conf/ext/sitepackage/Resources/Public/Icons/icon-thumbs-up.svg" alt="Hinweis"><p><strong>Wichtig zu wissen:</strong> Tierische Fette enthalten gesättigte Fettsäuren, die bei übermäßigem Verzehr das Risiko für Fettstoffwechselstörungen und Herz-Kreislauf-Erkrankungen erhöhen können. Ungesättigte Fettsäuren aus Pflanzen liefern zwar auch viele Kalorien, wirken sich aber zugleich positiv auf wichtige Stoffwechselprozesse aus. Greifen Sie deshalb so oft wie möglich auf pflanzliche Öle zurück – anstatt auf Butter und Schmalz.</p></div><h3>Fisch und Fleisch</h3><p>Fisch enthält wichtige Nährstoffe wie Selen, Jod und gesunde Omega-3-Fettsäuren. Letztere können das Risiko für <a href="/themen/herz-und-kreislauf">Herz-Kreislauf-Erkrankungen</a> wie einen <a href="/schlaganfall">Schlaganfall</a> mindern, da sie sich günstig auf Triglyzerid- und <a href="/hypercholesterinaemie">Cholesterinwerte</a> auswirken. Vor allem fettreiche Fische wie Lachs, Makrele, Hering und Forelle weisen hohe Gehalte an Omega-3-Fettsäuren auf. Ein- bis zweimal pro Woche gehört Fisch auf einen ausgewogenen Speiseplan, insbesondere fettreiche Sorten.</p><p>Anders als bei Fisch wird der Verzehr von Fleisch und Fleischprodukten nicht ausdrücklich von der DGE empfohlen. Fleisch ist zwar eine gute Eiweiß- und Eisenquelle und liefert viel Zink, Selen und Vitamin B12. Fleisch enthält aber auch viele gesättigte Fettsäuren. Rotes Fleisch – von Rind, Schwein, Schaf und Ziege – erhöht zudem das Risiko für <a href="/darmkrebs">Darmkrebs</a>. Daher wird empfohlen, pro Woche maximal 300 bis 600 Gramm Fleisch oder Wurst zu essen.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="vegetarisch-und-vegan" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Vegetarisch und vegan" data-title-desktop="Was versteht man unter vegetarischer und veganer Ernährung?">\n'+
    '            Was versteht man unter vegetarischer und veganer Ernährung?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Immer mehr Menschen entscheiden sich zum Wohl ihrer Gesundheit – aber auch aus Umweltschutz- und Tierschutzgründen – für eine vegetarische oder vegane Ernährung.</p><h3>Verzicht auf Fleisch: vegetarische Ernährung</h3><p>Eine abwechslungsreiche pflanzenbasierte Ernährung hat viele Vorteile. Denn wer viel Obst, Gemüse und Hülsenfrüchte isst, ernährt sich vitamin-, mineralstoff- und ballaststoffreich. Fleischverzicht oder ein geringer Fleischkonsum reduzieren zudem den Anteil tierischer Fette in der Nahrung. Milchprodukte und Eier sorgen für die notwendige Zufuhr an Eiweiß, Kalzium und Vitamin B12. Ihren Eisenbedarf können Menschen, die kein Fleisch essen, meist mit Vollkornprodukten, Nüssen, Ölsaaten und Hülsenfrüchten decken.</p><h3>Verzicht auf alle tierischen Produkte: vegane Ernährung</h3><p>Wer komplett auf tierische Produkte verzichten möchte, kann seinen Kalziumbedarf auch mit rein pflanzlicher Ernährung decken. Viel Kalzium steckt unter anderem in dunkelgrünen Gemüsesorten wie Spinat und Brokkoli, in Nüssen, Tofu und kalziumreichem Mineralwasser. Wer sich ausschließlich vegan ernährt, hat allerdings ein erhöhtes Risiko für einen <a href="/vitamin-b-mangel">Vitamin-B12-Mangel</a>, denn gute Vitamin-B12-Lieferanten sind vor allem Fleisch, Fisch, Meeresfrüchte, Eier und Milchprodukte. Veganerinnen und Veganern wird daher die dauerhafte Einnahme von Vitamin-B12-Präparaten dringend empfohlen.</p><p class="box grey-light additional-note">Mehr Tipps und Tricks für eine vegane Ernährung finden Sie in der Broschüre <a href="https://www.dge-medienservice.de/media/productattach/2/0/201030_dge_flyer_vegan_03_web.pdf" target="_blank" rel="noopener">„Vegan essen – klug kombinieren und ergänzen“</a> der Deutschen Gesellschaft für Ernährung (DGE).</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                        \n'+
    '\n'+
    '\n'+
    '\n'+
    '\n'+
    '    <section id="einkauf-und-zubereitung" class="col-12 col-lg-8 article-section">\n'+
    '\n'+
    '        <h2 class="article-offset" data-title-mobile="Einkauf und Zubereitung" data-title-desktop="Was kann man beim Einkauf und der Zubereitung beachten?">\n'+
    '            Was kann man beim Einkauf und der Zubereitung beachten?\n'+
    '        </h2>\n'+
    '\n'+
    '        <div class="article-section__content">\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Auch die Qualität eines Lebensmittels und seine Zubereitungsart entscheiden darüber, wie gesund ein Snack oder ein Gericht ist. In Fertiggerichten und Fast Food sind häufig große Mengen an Salz, Zucker und ungesunden Fetten versteckt. Wer stattdessen selbst kocht, hat mehr Kontrolle, wie gesund sie oder er isst. So sind in schonend zubereiteten Gerichten aus frischen Zutaten wesentlich mehr Vitamine und Mineralstoffe enthalten als in stark verarbeiteten Speisen.</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '                \n'+
    '<figure class="article-images__figure">\n'+
    '    \n'+
    '            <picture>\n'+
    '                <source media="(max-width: 576px)" srcset="https://gesund.bund.de/assets/gesunde_ernaehrung_einkauf_und_zubereitung-_mobil.svg">\n'+
    '                <source media="(min-width: 577px)" srcset="https://gesund.bund.de/assets/gesunde_ernaehrung_einkauf_und_zubereitung.svg">\n'+
    '                <img class="rs_skip article-full-width svg" src="https://gesund.bund.de/assets/gesunde_ernaehrung_einkauf_und_zubereitung.svg" alt="In Fertiggerichten und Fast Food sind häufig große Mengen an Salz, Zucker und ungesunden Fetten versteckt." title="Gesunde Ernährung Fast Food" loading="lazy" width="800" height="300">\n'+
    '            </picture>\n'+
    '        \n'+
    '\n'+
    '    \n'+
    '\n'+
    '</figure>\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '                \n'+
    '    \n'+
    '            <div class="article-offset">\n'+
    '    <p>Ein weiterer Vorteil des Selbstkochens ist, dass man auf unerwünschte Zusatzstoffe bewusst verzichten kann. Das kann vor allem für Menschen, die auf chemische Zusatzstoffe wie Geschmacksverstärker, Farbstoffe und Konservierungsmittel empfindlich reagieren, hilfreich sein. Unverträglichkeiten durch Zusatzstoffe in Lebensmitteln – auch „Pseudoallergien“ genannt – sind zwar nicht sehr häufig, können jedoch bei einigen Personen auftreten.</p><p>Die Wahl von Bio-Produkten kann helfen, <a href="/unerwuenschte-inhaltsstoffe-in-lebensmitteln">Rückstände von Pestiziden oder Antibiotika</a> im Essen zu reduzieren. Darüber hinaus ist es ratsam, reif geerntete, saisonale und regionale Lebensmittel zu bevorzugen. Durch lange Transportwege können Vitamine und Mineralstoffe verloren gehen und oft leidet auch der Geschmack darunter.</p><p class="box grey-light additional-note">Wie Sie schon beim Einkauf darauf achten können, Ihren Zucker-, Salz- und Fettverzehr zu senken, erfahren Sie auf der <a href="https://www.bzfe.de/lebensmittel/einkauf-und-kennzeichnung/weniger-zucker-fette-und-salz/" target="_blank" rel="noopener">Website des Bundeszentrums für Ernährung (BZfE)</a>.&nbsp;</p>\n'+
    '</div>\n'+
    '\n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '            \n'+
    '\n'+
    '         \n'+
    '        \n'+
    '\n'+
    '\n'+
    '            \n'+
    '        </div>\n'+
    '\n'+
    '    </section>\n'+
    '\n'+
    '\n'+
    '\n'+
    '                    \n'+
    '                    \n'+
    '                        <section id="quellen" class="col-12 col-lg-8 offset-lg-1 article-section accordion references ">\n'+
    '    <h2 class="accordion__header">\n'+
    '        <button aria-expanded="false" class="">\n'+
    '            Quellenangaben\n'+
    '        </button>\n'+
    '    </h2>\n'+
    '\n'+
    '    <div class="article-section__content">\n'+
    '        <ul><li>Bundesministerium für Ernährung und Landwirtschaft (BMEL). <a href="https://www.bmel.de/SharedDocs/Downloads/DE/Broschueren/ernaehrungsreport-2021.pdf?__blob=publicationFile&amp;v=5" target="_blank" rel="noopener">Deutschland, wie es isst. BMEL-Ernährungsreport 2021</a>.</li><li>Bundesministerium für Ernährung und Landwirtschaft (BMEL). <a href="https://in-form.de/fileadmin/Dokumente/Kompass_Ernaehrung/2019-1-kompass-ernaehrung-barrierefrei-neu.pdf" target="_blank" rel="noopener"> Kompass Ernährung. Einfach leichter essen mit Genuss und ohne Hunger</a>.  In Form. 1/2019.&nbsp;</li><li>Bundesministerium für Gesundheit. <a href="https://www.bundesgesundheitsministerium.de/fileadmin/Dateien/5_Publikationen/Praevention/Broschueren/2016_BMG_Praevention_Ratgeber_web.pdf" target="_blank" rel="noopener">Ratgeber zur Prävention und Gesundheitsförderung.</a> 9. aktualisierte Auflage. 01/2016.&nbsp;</li><li>Bundeszentrum für Ernährung (BZfE). <a href="https://www.bzfe.de/nachhaltiger-konsum/orientierung-beim-einkauf/bio-lebensmittel/" target="_blank" rel="noopener">Bio-Lebensmittel</a>. Aufgerufen am 06.12.2021.</li><li>Bundeszentrum für Ernährung (BZfE). <a href="https://www.bzfe.de/ernaehrung/die-ernaehrungspyramide/die-ernaehrungspyramide-eine-fuer-alle/" target="_blank" rel="noopener">Die Ernährungspyramide.</a> Aufgerufen am 06.12.2021.</li><li>Bundeszentrum für Ernährung (BZfE). <a href="https://www.bzfe.de/lebensmittel/vom-acker-bis-zum-teller/huelsenfruechte/huelsenfruechte-gesund-essen/" target="_blank" rel="noopener">Hülsenfrüchte: Gesund essen</a>. Aufgerufen am 06.12.2021.</li><li>Bundeszentrum für Ernährung (BZfE). <a href="https://www.bzfe.de/einfache-sprache/vegetarisch-essen/" target="_blank" rel="noopener">Vegetarisch essen.</a> Aufgerufen am 06.12.2021.</li><li>Deutsche Adipositas Gesellschaft (DAG), Deutsche Diabetes Gesellschaft (DDG) und Deutsche Gesellschaft für Ernährung (DGE). <a href="https://www.dge.de/fileadmin/public/doc/ws/stellungnahme/Konsensuspapier_Zucker_DAG_DDG_DGE_2018.pdf" target="_blank" rel="noopener">Quantitative Empfehlung zur Zuckerzufuhr in Deutschland</a>. Konsensuspapier. 12/2018.</li><li>Deutsche Gesellschaft für Ernährung (DGE).  <a href="https://www.dge.de/index.php?id=1023" target="_blank" rel="noopener">Ausgewählte Fragen und Antworten zu Vitamin B12</a>.  Aufgerufen am 03.12.2021.</li><li>Deutsche Gesellschaft für Ernährung (DGE). <a href="https://www.dge.de/wissenschaft/weitere-publikationen/faqs/salz/" target="_blank" rel="noopener">Ausgewählte Fragen und Antworten zu Speisesalz</a>. Aufgerufen am 10.12.2021.</li><li>Deutsche Gesellschaft für Ernährung (DGE). <a href="https://www.dge.de/fileadmin/public/doc/ws/stellungnahme/DGE-Stellungnahme-Gemuese-Obst-2012.pdf" target="_blank" rel="noopener">Gemüse und Obst in der Prävention ausgewählter chronischer Krankheiten</a>. Stellungnahme 2012.</li><li>Deutsche Gesellschaft für Ernährung (DGE). <a href="https://www.dge-medienservice.de/media/productattach/2/0/201030_dge_flyer_vegan_03_web.pdf" target="_blank" rel="noopener">Vegan essen – klug kombinieren und ergänzen</a>. 2. Aktualisierte Auflage. 2020.</li><li>Deutsche Gesellschaft für Ernährung. <a href="https://www.dge.de/ernaehrungspraxis/vollwertige-ernaehrung/10-regeln-der-dge/" target="_blank" rel="noopener">Vollwertig essen und trinken nach den 10 Regeln der DGE</a>. Aufgerufen am 10.12.2021.</li><li>Deutsche Gesellschaft für Ernährung (DGE), Sektion Schleswig-Holstein. <a href="https://www.dge-sh.de/geschmacksverst%C3%A4rker.html" target="_blank" rel="noopener">Geschmacksverstärker</a>. Aufgerufen am 09.12.2021.</li><li>Pietrowsky, R. Ernährung und Gesundheit. In: Gesundheitswissenschaften, Kapitel 28. Springer: Berlin 2019.</li></ul>\n'+
    '    </div>\n'+
    '</section>\n'+
    '                    \n'+
    '\n'+
    '                    <section class="col-12 col-lg-8">\n'+
    '    <div class="article-offset article-verification">\n'+
    '        \n'+
    '                <p class="article-verification__text">\n'+
    '                    Stand:\n'+
    '                    <span class="article-verification__date">\n'+
    '                        <time datetime="2022-04-14">\n'+
    '                            14.04.2022\n'+
    '                        </time>\n'+
    '                    </span>\n'+
    '                </p>\n'+
    '            \n'+
    '    </div>\n'+
    '</section>\n'+
    '                </div>\n'+
    '            </div>';