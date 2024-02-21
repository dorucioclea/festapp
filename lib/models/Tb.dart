class Tb
{
  static NewsTb news = const NewsTb();
  static UserInfoTb user_info = const UserInfoTb();
  static UserInfoPublicTb user_info_public = const UserInfoPublicTb();
  static UserNewsViewsTb user_news_views = const UserNewsViewsTb();
}
class NewsTb{
  const NewsTb();
  String get table => "news";
  String get id => "id";
  String get created_at => "created_at";
  String get created_by => "created_by";
  String get message => "message";
}
class UserInfoTb{
  const UserInfoTb();
  String get table => "user_info";
  String get id => "id";
  String get email_readonly => "email_readonly";
  String get name => "name";
  String get surname => "surname";
  String get sex => "sex";
  String get accommodation => "accommodation";
  String get phone => "phone";
  String get role => "role";
  String get birth_date => "birth_date";
  String get is_editor_readonly => "is_editor_readonly";
  String get is_admin_readonly => "is_admin_readonly";
}
class UserInfoPublicTb{
  const UserInfoPublicTb();
  String get table => "user_info_public";
  String get name => "name";
  String get surname => "surname";
}
class UserNewsViewsTb{
  const UserNewsViewsTb();
  String get table => "user_news_views";
}
