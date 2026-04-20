# Fuwari Project Instructions

This document defines the foundational mandates for document generation and maintenance in this workspace.

## Document Drafting Pipeline (Mandatory Workflow)

When an article title is provided, the agent MUST follow this iterative lifecycle:

### Phase 1: Blueprint & Initialization

1. **Analyze Title**: Determine the category and filename (kebab-case).
2. **Title Format**: Set `title` in frontmatter as `[folder_name] Actual Title` (where `folder_name` is the lowercase parent directory name).
3. **Generate Framework**: Create the Frontmatter, H2/H3 headers, and Fuwari extension placeholders (Admonitions; GitHub Cards ONLY if contextually relevant).
4. **Save & Pause**: Write the framework to `src/content/posts/[category]/[filename].md` and ask the user to: **"Confirm the outline to proceed to full drafting."**

### Phase 2: Full Content Generation & QC

1. **Continuous Drafting**: Once the blueprint is confirmed, write the entire article content following the approved structure.
2. **Quality Control (QC)**: Immediately after drafting, perform a self-audit:
   - **Accuracy Check**: Verify technical terms and logical consistency.
   - **Typography Check**: Ensure Fuwari tags (`:::note`, `::github`, etc.) are correctly formatted.
   - **Linting**: Align with project standards.
3. **Save**: Update the file with the complete, checked content.

### Phase 3: Final Acceptance

1. **Final Presentation**: Present the completed document structure and key highlights.
2. **Sign-off**: Ask the user: **"The document is complete and has passed QC. Any final adjustments before acceptance?"**

---

## Technical Specifications (Frontmatter)

- **Format**: YAML Frontmatter.
- **Fields**:
  - `title`: `[folder_name] Title Name` (The `folder_name` MUST be the lowercase name of the parent directory under `src/content/posts/`, excluding `example/`).
  - `published`: Current date (YYYY-MM-DD).
  - `description`: Engaging summary placeholder.
  - `image`: `''`.
  - `tags`: Array of 2-3 relevant tags.
  - `category`: MUST match the lowercase folder name (parent directory under `src/content/posts/`, excluding `example/`).
  - `draft`: `false`.

## Typography & Layout (Extended Markdown)

- **Admonitions**: Use `:::note`, `:::tip`, `:::important`, `:::warning`, `:::caution`.
- **GitHub Cards (Optional)**: Use `::github{repo="owner/repo"}` ONLY when referencing specific repositories.
- **Structure**: Mandatory "## 引言" and "## 总结".

### Writing Style & Rigor (Core Mandate)

- **Precision**: Focus strictly on technical content. Minimize the use of rhetorical modifiers, metaphors, and fluff unrelated to the core subject.
- **Tone**: Maintain a formal, rigorous, and professional tone suitable for a technical knowledge base.
- **Substance Over Style**: Prioritize clarity of information and accuracy of technical descriptions over stylistic flair.
