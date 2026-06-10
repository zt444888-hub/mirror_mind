import time

def log_info(message, method=None, params=None):
    timestamp = time.strftime("%H:%M:%S")
    log_msg = f"\033[36m[{timestamp}] INFO  \033[0m [SocialService]"
    if method:
        log_msg += f" \033[32m{method}()\033[0m"
    log_msg += f": {message}"
    if params and isinstance(params, dict):
        params_str = ", ".join([f"{k}=\033[33m{v}\033[0m" for k, v in params.items()])
        log_msg += f" | {params_str}"
    print(log_msg)

def log_success(message, method=None, params=None):
    timestamp = time.strftime("%H:%M:%S")
    log_msg = f"\033[32m[{timestamp}] SUCCESS\033[0m [SocialService]"
    if method:
        log_msg += f" \033[32m{method}()\033[0m"
    log_msg += f": \033[32m{message}\033[0m"
    if params and isinstance(params, dict):
        params_str = ", ".join([f"{k}=\033[33m{v}\033[0m" for k, v in params.items()])
        log_msg += f" | {params_str}"
    print(log_msg)

def log_warning(message, method=None, params=None):
    timestamp = time.strftime("%H:%M:%S")
    log_msg = f"\033[33m[{timestamp}] WARN  \033[0m [SocialService]"
    if method:
        log_msg += f" \033[33m{method}()\033[0m"
    log_msg += f": {message}"
    if params and isinstance(params, dict):
        params_str = ", ".join([f"{k}=\033[33m{v}\033[0m" for k, v in params.items()])
        log_msg += f" | {params_str}"
    print(log_msg)

def log_error(message, method=None, params=None):
    timestamp = time.strftime("%H:%M:%S")
    log_msg = f"\033[31m[{timestamp}] ERROR \033[0m [SocialService]"
    if method:
        log_msg += f" \033[31m{method}()\033[0m"
    log_msg += f": \033[31m{message}\033[0m"
    if params and isinstance(params, dict):
        params_str = ", ".join([f"{k}=\033[33m{v}\033[0m" for k, v in params.items()])
        log_msg += f" | {params_str}"
    print(log_msg)

def test_like_flow():
    liked_posts = set()
    
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│ 1. 测试点赞流程")
    print("└─────────────────────────────────────────────────────────────┘\n")
    
    log_info("called", method="likeMoodPost", params={"postId": "post_001", "alreadyLiked": False})
    log_info("starting Firestore transaction", method="likeMoodPost")
    log_info("transaction completed", method="likeMoodPost", params={"postId": "post_001", "newLikes": 42})
    log_info("saving to local cache", method="likeMoodPost", params={"postId": "post_001"})
    liked_posts.add("post_001")
    log_success("completed successfully", method="likeMoodPost", params={"postId": "post_001"})
    
    print()
    
    log_info("called", method="likeMoodPost", params={"postId": "post_001", "alreadyLiked": True})
    log_warning("skipped - already liked", method="likeMoodPost", params={"postId": "post_001"})
    
    print()
    
    log_info("called", method="unlikeMoodPost", params={"postId": "post_001", "isLiked": True})
    log_info("starting Firestore transaction", method="unlikeMoodPost")
    log_info("transaction completed", method="unlikeMoodPost", params={"postId": "post_001", "newLikes": 41})
    log_info("saving to local cache", method="unlikeMoodPost", params={"postId": "post_001"})
    liked_posts.remove("post_001")
    log_success("completed successfully", method="unlikeMoodPost", params={"postId": "post_001"})
    
    print()
    
    log_info("called", method="unlikeMoodPost", params={"postId": "post_001", "isLiked": False})
    log_warning("skipped - not liked", method="unlikeMoodPost", params={"postId": "post_001"})

def test_challenge_flow():
    joined_challenges = set()
    completed_days = {}
    
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│ 2. 测试挑战参与和打卡流程")
    print("└─────────────────────────────────────────────────────────────┘\n")
    
    log_info("called", method="joinChallenge", params={"challengeId": "challenge_001", "alreadyJoined": False})
    log_info("getting userId", method="joinChallenge")
    log_info("userId obtained", method="joinChallenge", params={"userId": "user_abc123"})
    log_info("starting Firestore transaction", method="joinChallenge")
    log_info("transaction started", method="joinChallenge")
    log_info("updated participants", method="joinChallenge", params={"from": 100, "to": 101})
    log_info("updated user challenges list", method="joinChallenge")
    log_info("saving to local cache", method="joinChallenge")
    joined_challenges.add("challenge_001")
    log_success("completed successfully", method="joinChallenge", params={"challengeId": "challenge_001"})
    
    print()
    
    log_info("called", method="joinChallenge", params={"challengeId": "challenge_001", "alreadyJoined": True})
    log_warning("skipped - already joined", method="joinChallenge", params={"challengeId": "challenge_001"})
    
    print()
    
    log_info("called", method="completeChallengeDay", params={"challengeId": "challenge_001", "day": "2024-01-01"})
    log_info("getting userId", method="completeChallengeDay")
    log_info("userId obtained", method="completeChallengeDay", params={"userId": "user_abc123"})
    log_info("getting participation snapshot", method="completeChallengeDay")
    log_info("no existing participation, creating new", method="completeChallengeDay")
    completed_days["challenge_001"] = ["2024-01-01"]
    log_info("new participation created", method="completeChallengeDay")
    log_success("completed successfully", method="completeChallengeDay")
    
    print()
    
    log_info("called", method="completeChallengeDay", params={"challengeId": "challenge_001", "day": "2024-01-01"})
    log_info("getting userId", method="completeChallengeDay")
    log_info("userId obtained", method="completeChallengeDay", params={"userId": "user_abc123"})
    log_info("getting participation snapshot", method="completeChallengeDay")
    log_info("existing participation found", method="completeChallengeDay", params={"completedDays": ["2024-01-01"]})
    log_warning("skipped - day already completed", method="completeChallengeDay", params={"day": "2024-01-01"})
    
    print()
    
    log_info("called", method="getCompletedDays", params={"challengeId": "challenge_001"})
    log_info("getting userId", method="getCompletedDays")
    log_info("userId obtained", method="getCompletedDays", params={"userId": "user_abc123"})
    log_info("getting snapshot", method="getCompletedDays")
    log_info("found completed days", method="getCompletedDays", params={"completedDays": ["2024-01-01"]})

def test_treehole_flow():
    comforted_holes = set()
    
    print("\n┌─────────────────────────────────────────────────────────────┐")
    print("│ 3. 测试树洞安慰流程")
    print("└─────────────────────────────────────────────────────────────┘\n")
    
    log_info("called", method="comfortTreeHolePost", params={"postId": "hole_001", "alreadyComforted": False})
    log_info("starting Firestore transaction", method="comfortTreeHolePost")
    log_info("transaction started", method="comfortTreeHolePost", params={"postId": "hole_001"})
    log_info("transaction completed", method="comfortTreeHolePost", params={"postId": "hole_001", "newComforts": 15})
    log_info("saving to local cache", method="comfortTreeHolePost", params={"postId": "hole_001"})
    comforted_holes.add("hole_001")
    log_success("completed successfully", method="comfortTreeHolePost", params={"postId": "hole_001"})
    
    print()
    
    log_info("called", method="comfortTreeHolePost", params={"postId": "hole_001", "alreadyComforted": True})
    log_warning("skipped - already comforted", method="comfortTreeHolePost", params={"postId": "hole_001"})

if __name__ == "__main__":
    print("\n" + "═"*70)
    print("              心镜社交服务日志输出测试演示")
    print("═"*70)
    
    test_like_flow()
    test_challenge_flow()
    test_treehole_flow()
    
    print("\n" + "═"*70)
    print("                       测试完成")
    print("═"*70 + "\n")