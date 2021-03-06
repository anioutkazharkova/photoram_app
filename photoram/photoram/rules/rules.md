#  Rules

#### Standard rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write
    }
  }
}
```


#### Authorized only
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    match /users/{user} {
          allow read, write: if (signedIn() == true);
        }
   match /posts/{post} {
       allow read, write: if (signedIn() == true);
    }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```
### Only author edit
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    match /users/{user} {
          allow read, write: if (signedIn() == true);
        }
   match /posts/{post} {
       allow read, write: if (signedIn() == true);
       allow update:  if (request.auth != null && request.auth.uid == request.resource.data.userId);
    }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```

### Only author edit. Likes for other
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    match /users/{user} {
          allow read, write: if (signedIn() == true);
        }
   match /posts/{post} {
       allow read, write: if (signedIn() == true);
       allow update:  if ((request.auth != null && request.auth.uid == request.resource.data.userId) ||  
       request.resource.data.diff(resource.data).affectedKeys()
        .hasOnly(['likeItems']));
    }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```
### Only author edit. Likes for other. Comments
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    match /users/{user} {
          allow read, write: if (signedIn() == true);
        }
    match /posts/{post} {
       allow read: if (signedIn() == true);
       allow write: if (request.auth != null && request.auth.uid == request.resource.data.userId);
       allow update:  if ((request.auth != null && request.auth.uid == request.resource.data.userId) ||  
       request.resource.data.diff(resource.data).affectedKeys()
        .hasAny(['likeItems', "comments"]));
    }

   match /posts/{post}/comments/{comment} {
            allow read, write: if (signedIn() == true);
  }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```

### With user
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    
    match /users/{user} {
      allow read, write: if (signedIn() == true);
    }
 
    match /posts/{post} {
       allow read: if (signedIn() == true);
       allow write: if (request.auth != null && request.auth.uid == request.resource.data.userId);
       allow update:  if ((request.auth != null && request.auth.uid == request.resource.data.userId) ||  
       request.resource.data.diff(resource.data).affectedKeys()
        .hasAny(['likeItems', "comments"]));
    }

   match /posts/{post}/comments/{comment} {
            allow read, write: if (signedIn() == true);
  }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```

### With delete

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
   function signedIn() {
      return request.auth.uid != null;
    }
    match /users/{user} {
          allow read, write: if (signedIn() == true);
        }
    match /posts/{post} {
       allow read: if (signedIn() == true);
       allow write, delete: if (request.auth != null && request.auth.uid == request.resource.data.userId);
       allow update:  if ((request.auth != null && request.auth.uid == request.resource.data.userId) ||  
       request.resource.data.diff(resource.data).affectedKeys()
        .hasAny(['likeItems', "comments"]));
    }

   match /posts/{post}/comments/{comment} {
            allow read, write: if (signedIn() == true);
  }
   match /comments/{comment} {
               allow read, write: if (signedIn() == true);
   } 
  }
}
```
