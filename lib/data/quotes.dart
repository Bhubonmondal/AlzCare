import 'dart:math';

String quotes() {
  List<String> quotes = [
    "Wherever the art of medicine is loved, there is also a love of humanity.",
    "To cure sometimes, to relieve often, to comfort always.",
    "A good physician treats the disease; a great physician treats the patient who has the disease.",
    "Healing is an art. Medicine is a science. Caring is a calling.",
    "Your hands are capable of healing; your heart is capable of hope.",
    "In saving others, we discover the deeper purpose of our lives.",
    "Doctors may give medicine, but only nature heals.",
    "Every patient carries their own doctor inside them.",
    "Behind every prescription is a life, a family, a hope.",
    "The best way to find yourself is to lose yourself in the service of others.",
    "Your present circumstances don’t determine where you go; they merely determine where you start.",
    "Healing takes courage, and we all have courage, even if we have to dig a little to find it.",
    "You are not a diagnosis. You are a warrior fighting an invisible battle.",
    "The human spirit is stronger than anything that can happen to it.",
    "It always seems impossible until it’s done.",
    "One day at a time, one breath at a time, one step closer to healing.",
    "You may not control the storm, but you can learn to dance in the rain.",
    "Pain is real. But so is hope.",
    "Scars are proof that you were stronger than what tried to hurt you.",
    "Even the darkest night will end, and the sun will rise.",
    "Compassion is just as important as knowledge in healing.",
    "The best doctors give the gift of hope as well as medicine.",
    "In treating others, we become more human ourselves.",
    "Hope is the first dose of every successful treatment.",
    "Every heartbeat is a victory.",
    "A kind word can be as powerful as the strongest drug.",
    "You’re braver than your illness believes.",
    "Don’t count the days — make the days count.",
    "Listen to your body; it whispers before it screams.",
    "Healing begins with hope and thrives on trust.",
    "The smallest act of care is worth more than the grandest intention.",
    "There is no medicine like hope, no tonic so powerful as courage.",
    "Sometimes, listening is the best medicine a doctor can give.",
    "Your story isn’t over; this is just a challenging chapter.",
    "Patience and persistence are part of every cure.",
    "Health is not just the absence of disease, but the presence of peace.",
    "In the eyes of a patient, a smile is medicine.",
    "Being sick doesn’t make you weak — it makes you a fighter.",
    "Doctors stitch wounds, but compassion heals hearts.",
    "Every day you fight is a day you win.",
    "You’re healing, even if you don’t feel it yet.",
    "Never underestimate the power of a hopeful mind.",
    "Recovery is not a race — it’s a journey.",
    "Your courage inspires more than you know.",
    "Doctors are the bridge between suffering and relief.",
    "The strength to heal lies within, medicine just helps unlock it.",
    "Every patient deserves to be heard before being treated.",
    "The body heals with rest, the mind heals with hope, and the heart heals with love.",
    "To be a doctor is to hold another’s life with care and purpose.",
    "Healing happens when science and empathy meet.",
  ];

  DateTime now = DateTime.now();
  int seed = now.year * 10000 + now.month * 100 + now.day;
  int index = seed % quotes.length;

  return quotes[index];

}