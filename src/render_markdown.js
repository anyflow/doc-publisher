
const { Octokit } = require('@octokit/core')

const octokit = new Octokit({
  auth: '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'
})

const fs = require('fs');

const dir = './output';
if (fs.existsSync(dir)) {
  fs.rmSync(dir, { recursive: true });
}
fs.mkdirSync(dir);

const markdown = fs.readFileSync('./MANIFEST.md', 'utf8')
const template = fs.readFileSync('./template.html', 'utf8')

async function main() {
  const result = await octokit.request('POST /markdown', {
    text: markdown,
    headers: {
      'X-GitHub-Api-Version': '2022-11-28'
    }
  })

  const htmlContent = template.replace('<article class="markdown-body">', '<article class="markdown-body">' + result.data);

  fs.writeFile('./output/manifest.html', htmlContent, function (err) {
    if (err) throw err;
    console.log('Saved!');
  });

}

main();
