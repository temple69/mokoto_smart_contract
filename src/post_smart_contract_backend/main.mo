// Import necessary modules
import Debug "mo:base/Debug";
import List "mo:base/List";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Principal "mo:base/Principal";
import Bool "mo:base/Bool";

// Define the main actor
actor {
  // Define a Post data type
type Post = {
    id: Nat;
    title: Text;
    content: Text;
    author: Text;
    createdAt: Time.Time;
    upvotes: Nat;
    downvotes: Nat;
    
};

    // Storage for posts and next ID
    var posts: List.List<Post> = List.nil<Post>();
    var nextId: Nat = 0;
//
    public shared ({ caller }) func returnCallerPrincipal() : async Principal {

        return caller;
    };

    // Function to create a new post
public func createPost(title: Text, content: Text, author: Text): async Nat {
    let postId = nextId;
    nextId += 1;

    
    // Get the caller's Principal

let principal = await returnCallerPrincipal();
Debug.print("Caller Principal: " # Principal.toText(principal));


    let newPost: Post = {
        id = postId;
        title = title;
        content = content;
        author = author;
        createdAt = Time.now();
        upvotes = 0;
        downvotes = 0
      
    };
     // Correctly append the new post to the list using List.append
    posts := List.push<Post>(newPost, posts);
    Debug.print("Post created with ID " # Nat.toText(postId));
    return postId;

   
};
// Function to retrieve all posts
public func getPosts(): async [Post] {
    return List.toArray(posts);  // Convert List to Array for the return type
};
// Function to get a single post by ID
    public func getPostById(postId: Nat): async ?Post {
        return List.find<Post>(posts, func (post) { post.id == postId });
    };

    // Function to upvote a post by ID
    public func upvotePost(postId: Nat): async Bool {
        var found = false;
        posts := List.map<Post,Post>(posts, func (post) {
            if (post.id == postId) {
                found := true;
                { post with upvotes = post.upvotes + 1 };
            } else {
                post;
            }
        });
        return found;
    };

    // Function to downvote a post by ID
    public func downvotePost(postId: Nat): async Bool {
        var found = false;
        posts := List.map<Post,Post>(posts, func (post) {
            if (post.id == postId) {
                found := true;
                { post with downvotes = post.downvotes + 1 };
            } else {
                post;
            }
        });
        return found;
    };

    // Optional: Function to delete a post by ID
    public func deletePost(postId: Nat): async Bool {
        let (foundPost, updatedPosts) = List.partition<Post>(posts, func (post) { post.id == postId });
        
        if (List.size(foundPost) > 0) {
            posts := updatedPosts;
            return true;
        } else {
            return false;
        };
    };
    public func editPost(postId: Nat, newTitle: Text, newContent: Text): async Bool {
        //let callerPrincipal = Principal.fromActor(Actor.caller()); // Get the caller's Principal
        var found = false;

        posts := List.map<Post,Post>(posts, func (post) : Post {
            if (post.id == postId) {
              found := true;
              return { post with title = newTitle; content = newContent }; // Edit post
                
            } else {
                return post;
            }
        });

        return found; // Return true if post was found and edited
    };
    //Function to get all posts by a specific author
    public func getPostsByAuthor(author: Text): async  (List.List<Post>) {
        List.filter<Post>(posts, func (post) { post.author == author });
    }; 
}

