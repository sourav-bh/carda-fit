class DataLoader {
  static const List<String> quotes = ['¨Exercise is labor without weariness¨',
    '¨The clock is ticking. Are you becoming the person you want to be?¨',
    '¨A feeble body weakens the mind¨',
    '¨Our bodies are our gardens – our wills are our gardeners¨',
    '¨Don’t count the days, make the days count¨',
    '¨Nothing will work unless you do¨',
    '¨Fitness: if it came in a bottle, everyone would have a great body¨'];
  static const List<String> quotesAuthor = ['Samuel Johnson', 'Greg Plitt, fitness model', 'Jean-Jacques Rousseau',
    'William Shakespeare', 'Muhammad Ali', 'John Wooden', 'Cher'];
}

class FitnessItemInfo {
  late int id;
  late String image;
  late String name;
  late int count;
  late int target;
  late int points;

  FitnessItemInfo(this.id, this.image, this.name, this.count, this.target, this.points);

  static List<FitnessItemInfo> generateDummyList() {
    List<FitnessItemInfo> data = List.empty(growable: true);
    data.add(FitnessItemInfo(12920, 'assets/animations/anim_water.gif', 'Water', 5, 8, 5));
    data.add(FitnessItemInfo(12921, 'assets/animations/anim_steps.gif', 'Steps', 3041, 8156, 1));
    data.add(FitnessItemInfo(12922, 'assets/animations/anim_break_time.gif', 'Breaks', 4, 10, 10));
    data.add(FitnessItemInfo(12923, 'assets/animations/anim_fitness_1.gif', 'Exercise', 2, 6, 25));
    return data;
  }
}

class LearningMaterialInfo {
  late int id;
  late String thumbnail;
  late String image;
  late String title;
  late String description;
  late String detailsUrl;
  late String videoUrl;

  LearningMaterialInfo(this.id, this.thumbnail, this.image, this.title, this.description, this.detailsUrl, this.videoUrl);

  static List<LearningMaterialInfo> generateDummyList() {
    String foodDetails =  '   <div class="entry-content">  '  +
        '   		<p><img class="alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/carbs1.jpg" alt="Carbohydrates" width="79" height="69">1. Choose good carbs, not no carbs. Whole grains are your best bet.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><span id="more-8622"></span></p>  '  +
        '   <p><img data-attachment-id="4093" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/protein-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/protein-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="protein-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/protein-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/protein-icon.jpg" loading="lazy" class="size-full wp-image-4093 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/protein-icon.jpg" alt="protein-icon" width="80" height="65"> 2. Pay attention to the protein package. Fish, poultry, nuts, and beans are the best choices.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3858" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/fats-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fats-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="fats-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fats-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fats-icon.jpg" loading="lazy" class="size-full wp-image-3858 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fats-icon.jpg" alt="fats-icon" width="80" height="65"> 3. Choose foods with healthy fats, limit foods high in saturated fat, and avoid foods with trans fat. Plant oils, nuts, and fish are the healthiest sources.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3868" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/fiber-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fiber-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="fiber-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fiber-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fiber-icon.jpg" loading="lazy" class="size-full wp-image-3868 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/fiber-icon.jpg" alt="fiber-icon" width="80" height="65"> 4. Choose a fiber-filled diet, rich in whole grains, vegetables, and fruits.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="4285" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/vegetables-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vegetables-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="vegetables-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vegetables-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vegetables-icon.jpg" loading="lazy" class="size-full wp-image-4285 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vegetables-icon.jpg" alt="vegetables-icon" width="80" height="65">5. Eat more vegetables and fruits. Go for color and variety—dark green, yellow, orange, and red.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3995" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/milk-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/milk-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="milk-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/milk-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/milk-icon.jpg" loading="lazy" class="size-full wp-image-3995 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/milk-icon.jpg" alt="milk-icon" width="80" height="65">6. Calcium is important. But milk isn’t the only, or even best, source.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3924" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/healthier-drinks-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/healthier-drinks-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="healthier-drinks-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/healthier-drinks-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/healthier-drinks-icon.jpg" loading="lazy" class="size-full wp-image-3924 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/healthier-drinks-icon.jpg" alt="healthier-drinks-icon" width="80" height="65">7. Water is best to quench your thirst. Skip the sugary drinks, and go easy on the milk and juice.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3649" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/salt-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/salt-icon.gif" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="salt-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/salt-icon.gif" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/salt-icon.gif" loading="lazy" class="size-full wp-image-3649 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/salt-icon.gif" alt="salt-icon" width="80" height="65">8. Eating less salt is good for everyone’s health. Choose more fresh foods and fewer processed foods.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="3706" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/alcohol-icon/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/alcohol-icon.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="alcohol-icon" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/alcohol-icon.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/alcohol-icon.jpg" loading="lazy" class="size-full wp-image-3706 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/alcohol-icon.jpg" alt="alcohol-icon" width="80" height="65">9. Moderate drinking can be healthy—but not for everyone. You must weigh the benefits and risks.</p>  '  +
        '   <p>&nbsp;</p>  '  +
        '   <p><img data-attachment-id="4322" data-permalink="https://www.hsph.harvard.edu/nutritionsource/2013/11/06/healthy-eating-ten-nutrition-tips-for-eating-right/vitamins-small-home/" data-orig-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vitamins-small-home.jpg" data-orig-size="80,65" data-comments-opened="0" data-image-meta="{&quot;aperture&quot;:&quot;0&quot;,&quot;credit&quot;:&quot;&quot;,&quot;camera&quot;:&quot;&quot;,&quot;caption&quot;:&quot;&quot;,&quot;created_timestamp&quot;:&quot;0&quot;,&quot;copyright&quot;:&quot;&quot;,&quot;focal_length&quot;:&quot;0&quot;,&quot;iso&quot;:&quot;0&quot;,&quot;shutter_speed&quot;:&quot;0&quot;,&quot;title&quot;:&quot;&quot;}" data-image-title="vitamins-small-home" data-image-description="" data-image-caption="" data-medium-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vitamins-small-home.jpg" data-large-file="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vitamins-small-home.jpg" loading="lazy" class="size-full wp-image-4322 alignleft" src="https://cdn1.sph.harvard.edu/wp-content/uploads/sites/30/2012/10/vitamins-small-home.jpg" alt="vitamins-small-home" width="80" height="65">10. A daily multivitamin is a great nutrition insurance policy. Some extra vitamin D may add an extra health boost.</p>  '  +
        '  		</div>  ' ;

    List<LearningMaterialInfo> data = List.empty(growable: true);
    data.add(LearningMaterialInfo(13720, 'assets/images/thumb_posture_error.png', '', 'How to Fix Your Sitting Posture?', 'Watch this video to quickly learn ways to fix your posture', '', 'https://www.youtube.com/watch?v=RqcOCBb4arc'));
    data.add(LearningMaterialInfo(13721, 'assets/images/thumb_nutir_foods.png', 'assets/images/nutri_food_banner.png', '10 Guidelines for Eating Healthy Foods', foodDetails, '', ''));
    data.add(LearningMaterialInfo(13722, 'assets/images/thumb_office_exercises.png', '', 'Right Way to Do Exercises in a Workplace', 'Read details about correct ways for doing quick exercises in your office', 'https://www.healthline.com/health/fitness/office-exercises#exercises-while-standing', ''));
    return data;
  }
}

class LeaderboardParticipantInfo {
  late String name;
  late int points;

  LeaderboardParticipantInfo(this.name, this.points);

  static List<LeaderboardParticipantInfo> generateDummyList() {
    List<LeaderboardParticipantInfo> data = List.empty(growable: true);
    data.add(LeaderboardParticipantInfo('Daniel', 158));
    data.add(LeaderboardParticipantInfo('Max', 177));
    data.add(LeaderboardParticipantInfo('Carolina', 165));
    data.add(LeaderboardParticipantInfo('Vicky', 110));
    data.add(LeaderboardParticipantInfo('Julia', 85));
    data.add(LeaderboardParticipantInfo('Ben', 105));
    data.add(LeaderboardParticipantInfo('Victoria', 141));
    data.add(LeaderboardParticipantInfo('Francis', 180));
    return data;
  }
}