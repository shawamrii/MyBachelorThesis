const express = require('express');
const multer = require('multer');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');
const app = express();
const port = 3000;
/*
const allowedOrigins = ['http://localhost:8081','http://localhost:8080'];
// Add Cross Origins
app.use(cors({
  origin: (origin, callback) => {
    // Allow requests with no origin
    // (like mobile apps or curl requests)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) === -1) {
      var msg = 'The CORS policy for this site does not ' +
                'allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    return callback(null, true);
  }
}));
*/

//for any Origin
app.use(cors({
  origin: true
}));


//app.use(cors());
app.use(express.json());

// Ensure the 'uploads' directory exists
const uploadsDir = path.join(__dirname, 'uploads');
fs.mkdirSync(uploadsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const timestamp = Date.now();
    const filename = timestamp + '-' + file.originalname;
    cb(null, filename);
  }
});

const upload = multer({ storage: storage }).single('file');

app.get('/', (req, res) => {
  const uploadsPath = path.join(__dirname, 'uploads');

  fs.readdir(uploadsPath, (err, files) => {
    if (err) {
      console.error('Error reading uploads directory:', err);
      return res.status(500).send('Server error when trying to list files.');
    }

    let html = '<h1>Uploaded Files</h1>';
    html += '<ul>';
    files.forEach(file => {
      html += `<li><a href="/uploads/${file}" target="_blank">${file}</a></li>`;
    });
    html += '</ul>';

    res.send(html);
  });
});

function generateRandomId(length) {
  const characters = '0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}
// Endpoint to generate a unique ID and create a file
app.get('/generate-id', (req, res) => {
  const uniqueId = generateRandomId(4);
  const filename = `file_${uniqueId}.json`;
  const filepath = path.join(uploadsDir, filename);

  fs.writeFile(filepath, '', (err) => {
    if (err) {
      console.error('Error creating file:', err);
      return res.status(500).send('Error creating file.');
    }
    res.send({ id: uniqueId, filename: filename });
  });
});


// Endpoint to upload JSON data to a specific file
app.post('/upload/:filename', (req, res) => {
  const jsonData = req.body;
  const { filename } = req.params;
  const filepath = path.join(uploadsDir, filename);

  fs.readFile(filepath, 'utf8', (err, data) => {
    if (err) {
      console.error('Error reading file:', err);
      return res.status(500).send('Error reading file.');
    }

    let fileContent;
    try {
      fileContent = JSON.parse(data);
    } catch (parseError) {
      return res.status(500).send('Error parsing JSON in file.');
    }

    fileContent = fileContent.concat(jsonData);

    fs.writeFile(filepath, JSON.stringify(fileContent, null, 2), (writeErr) => {
      if (writeErr) {
        console.error('Error writing JSON to file:', writeErr);
        return res.status(500).send('Error writing JSON to file.');
      }
      res.status(200).send({ message: 'JSON appended successfully.' });
    });
  });
});

//Admin endpoints start
app.get('/files', (req, res) => {
  fs.readdir(uploadsDir, (err, files) => {
    if (err) {
      console.error('Error reading uploads directory:', err);
      return res.status(500).send('Error reading uploads directory.');
    }

    const fileList = files.map(file => {
      return {
        filename: file,
        // Add additional file details here if needed
      };
    });

    res.json(fileList);
  });
});
// Endpoint to get the content of a specific file
app.get('/file-content/:filename', (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(uploadsDir, filename);

  fs.readFile(filepath, 'utf8', (err, data) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Error reading file');
    }
    res.send(data);
  });
});


app.delete('/files/:filename', (req, res) => {
  const { filename } = req.params;
  const filepath = path.join(uploadsDir, filename);

  fs.unlink(filepath, (err) => {
    if (err) {
      console.error('Error deleting file:', err);
      return res.status(500).send('Error deleting file.');
    }
    res.send({ message: `File ${filename} deleted successfully.` });
  });
});

app.put('/edit/:filename', (req, res) => {
  const { filename } = req.params;
  const newContent = req.body.newContent;
  const filepath = path.join(uploadsDir, filename);

  fs.writeFile(filepath, newContent, (err) => {
    if (err) {
      console.error('Error writing to file:', err);
      return res.status(500).send('Error writing to file.');
    }
    res.send({ message: `File ${filename} updated successfully.` });
  });
});


app.post('/create', (req, res) => {
  const content = req.body.content;
  const uniqueId = generateRandomId(4); // Using your existing function
  const filename = `file_${uniqueId}.json`;
  const filepath = path.join(uploadsDir, filename);

  fs.writeFile(filepath, JSON.stringify([], null, 2), (err) => {
    if (err) {
      console.error('Error creating file:', err);
      return res.status(500).send('Error creating file.');
    }
    res.send({ message: `File ${filename} created successfully.` });
  });
});



app.post('/upload', upload, (req, res) => {
  // req.file is the 'file' uploaded
  console.log(req.file);
  res.send({ message: `File uploaded successfully: ${req.file.filename}` });
});


//Admin endpoints end


app.use('/uploads', express.static('uploads'));

app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
  console.log(`Server listening at http://10.0.2.2:${port}`);
});
