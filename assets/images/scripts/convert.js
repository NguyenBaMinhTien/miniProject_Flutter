const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

const directories = [
  path.join(__dirname, '../horse'),
  path.join(__dirname, '../road')
];

async function convertAll() {
  for (const dir of directories) {
    if (!fs.existsSync(dir)) continue;
    const files = fs.readdirSync(dir);
    for (const file of files) {
      if (file.endsWith('.svg')) {
        const svgPath = path.join(dir, file);
        const pngPath = path.join(dir, file.replace('.svg', '.png'));
        
        console.log(`Converting ${file}...`);
        try {
          // Some massive SVGs might need higher density or specific sizes,
          // but sharp parses them usually very fast.
          await sharp(svgPath)
            .png()
            .toFile(pngPath);
          console.log(`Successfully converted ${file} to PNG.`);
        } catch (e) {
          console.error(`Error converting ${file}:`, e);
        }
      }
    }
  }
}

convertAll();
