import 'package:idris_db/idris_db.dart';
import 'package:idris_db_test/idris_db_test.dart';
import 'package:idris_db_test/src/twitter/tweet.dart';
import 'package:test/test.dart';

void main() {
  group('JSON', () {
    late IdrisDb IdrisDb;

    setUp(() async {
      IdrisDb = await openTempIDRISDB([TweetSchema]);
    });

    IdrisDbTest('Import', () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.tweets.importJson([tweetJson]);
      });

      final tweets = IdrisDb.tweets.where().findAll();
      expect(tweets.length, 1);
      expect(tweets[0].IDRISDBId, 372526);
      expect(tweets[0].idStr, '602584278883553280');
      expect(tweets[0].user?.screenName, 'rosa_cinque');
    });

    IdrisDbTest('Import / Export', () {
      IdrisDb.write((IdrisDb) {
        IdrisDb.tweets.importJson([tweetJson]);
      });

      final exported = IdrisDb.tweets.where().exportJson();
      expect(exported.length, 1);
    });
    IdrisDbTest('Import raw malformed empty', () {
      expect(
        () => IdrisDb.write((IdrisDb) {
          IdrisDb.tweets.importJsonString('');
        }),
        throwsIDRISDBError(),
      );
    });

    IdrisDbTest('Import raw malformed object', () {
      expect(
        () => IdrisDb.write((IdrisDb) {
          IdrisDb.tweets.importJsonString('[{}]');
        }),
        throwsIDRISDBError(),
      );
    });
  });
}

const Map<String, Object?> tweetJson = {
  'coordinates': {
    'coordinates': [14.48532271, 40.63070878],
    'type': 'Point',
  },
  'createdAt': 1432502262000000,
  'currentUserRetweet': null,
  'displayTextRange': [0, 123],
  'entities': {
    'hashtags': [
      {
        'indices': [42, 51],
        'text': 'foodporn',
      },
      {
        'indices': [52, 64],
        'text': 'gialloblogs',
      },
      {
        'indices': [65, 87],
        'text': 'RicetteBloggerRiunite',
      },
      {
        'indices': [88, 97],
        'text': 'Expo2015',
      },
    ],
    'media': [
      {
        'additionalMediaInfo': null,
        'displayUrl': 'pic.twitter.com/yFgRfzL6DF',
        'expandedUrl':
            'https://twitter.com/caterinaboagno/status/602408908561473536/photo/1',
        'idStr': '602408906787291136',
        'indices': [98, 120],
        'mediaUrl': 'http://pbs.twimg.com/media/CFwvtYKWgAAaOV9.jpg',
        'mediaUrlHttps': 'https://pbs.twimg.com/media/CFwvtYKWgAAaOV9.jpg',
        'sizes': {
          'large': {'h': 450, 'resize': 'fit', 'w': 600},
          'medium': {'h': 450, 'resize': 'fit', 'w': 600},
          'small': {'h': 450, 'resize': 'fit', 'w': 600},
          'thumb': {'h': 150, 'resize': 'crop', 'w': 150},
        },
        'sourceStatusIdStr': '602408908561473536',
        'type': 'photo',
        'url': 'http://t.co/yFgRfzL6DF',
        'videoInfo': null,
      },
    ],
    'polls': null,
    'symbols': <dynamic>[],
    'urls': [
      {
        'displayUrl': 'blog.giallozafferano.it/lacucinadikaty…',
        'expandedUrl':
            'http://blog.giallozafferano.it/lacucinadikaty/cheesecake-frutta/',
        'indices': [18, 40],
        'url': 'http://t.co/S8yyMcL62d',
      },
    ],
    'userMentions': [
      {
        'idStr': '993103729',
        'indices': [1, 16],
        'name': 'La cucina di katy',
        'screenName': 'caterinaboagno',
      },
    ],
  },
  'extendedEntities': {
    'hashtags': null,
    'media': [
      {
        'additionalMediaInfo': null,
        'displayUrl': 'pic.twitter.com/yFgRfzL6DF',
        'expandedUrl':
            'https://twitter.com/caterinaboagno/status/602408908561473536/photo/1',
        'idStr': '602408906787291136',
        'indices': [98, 120],
        'mediaUrl': 'http://pbs.twimg.com/media/CFwvtYKWgAAaOV9.jpg',
        'mediaUrlHttps': 'https://pbs.twimg.com/media/CFwvtYKWgAAaOV9.jpg',
        'sizes': {
          'large': {'h': 450, 'resize': 'fit', 'w': 600},
          'medium': {'h': 450, 'resize': 'fit', 'w': 600},
          'small': {'h': 450, 'resize': 'fit', 'w': 600},
          'thumb': {'h': 150, 'resize': 'crop', 'w': 150},
        },
        'sourceStatusIdStr': '602408908561473536',
        'type': 'photo',
        'url': 'http://t.co/yFgRfzL6DF',
        'videoInfo': null,
      },
    ],
    'polls': null,
    'symbols': null,
    'urls': null,
    'userMentions': null,
  },
  'favoriteCount': 2,
  'favorited': false,
  'fullText':
      '"@caterinaboagno: http://t.co/S8yyMcL62d\n\n#foodporn #gialloblogs #RicetteBloggerRiunite #Expo2015 http://t.co/yFgRfzL6DF" 😍',
  'idStr': '602584278883553280',
  'inReplyToScreenName': 'caterinaboagno',
  'inReplyToStatusIdStr': '602408908561473536',
  'inReplyToUserIdStr': '993103729',
  'isQuoteStatus': false,
  'IDRISDBId': 372526,
  'lang': 'und',
  'place': {
    'country': 'Italien',
    'countryCode': 'IT',
    'fullName': 'Positano, Kampanien',
    'id': 'ab6034f6c3eb69c8',
    'name': 'Positano',
    'placeType': 'city',
    'url': 'https://api.twitter.com/1.1/geo/id/ab6034f6c3eb69c8.json',
  },
  'possiblySensitive': false,
  'possiblySensitiveAppealable': null,
  'quoteCount': null,
  'quotedStatusIdStr': null,
  'quotedStatusPermalink': null,
  'replyCount': null,
  'retweetCount': 3,
  'retweeted': false,
  'source':
      '<a href="http://www.twitter.com" rel="nofollow">Twitter for Windows Phone</a>',
  'truncated': false,
  'user': {
    'createdAt': 1409213170000000,
    'defaultProfile': true,
    'defaultProfileImage': false,
    'description': 'Born&Living in Positano ❤',
    'entities': {
      'description': {'urls': <dynamic>[]},
      'url': null,
    },
    'favoritesCount': null,
    'followersCount': 1671,
    'friendsCount': 2293,
    'idStr': '2753148281',
    'listedCount': 32,
    'location': 'Positano',
    'name': 'Rosa Cinque',
    'profileBannerUrl':
        'https://pbs.twimg.com/profile_banners/2753148281/1519746619',
    'profileImageUrlHttps':
        'https://pbs.twimg.com/profile_images/784521636955451393/Xwp0rcPc_normal.jpg',
    'protected': false,
    'screenName': 'rosa_cinque',
    'statusesCount': 4901,
    'url': null,
    'verified': false,
    'withheldInCountries': <dynamic>[],
    'withheldScope': null,
  },
};
