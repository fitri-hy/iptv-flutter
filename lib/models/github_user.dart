class GitHubUser {
  final String login;
  final String name;
  final String avatarUrl;
  final String bio;
  final String htmlUrl;
  final int followers;
  final int following;
  final int publicRepos;

  GitHubUser({
    required this.login,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.htmlUrl,
    required this.followers,
    required this.following,
    required this.publicRepos,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'] ?? '',
      htmlUrl: json['html_url'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      publicRepos: json['public_repos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'login': login,
        'name': name,
        'avatar_url': avatarUrl,
        'bio': bio,
        'html_url': htmlUrl,
        'followers': followers,
        'following': following,
        'public_repos': publicRepos,
      };
}
