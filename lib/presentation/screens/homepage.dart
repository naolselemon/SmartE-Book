import 'package:flutter/material.dart';
import '../widgets/bookdetailcontainer.dart';
import '../widgets/sectiontitle.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(title: 'Trending Books'),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:[
                  BookDetailContainer(
                    imagePath: 'assets/images/book1.png',
                    title: 'Atomic Habits',
                    author: 'James Clear',
                    rating: 4.9,
                    reviews: 180,
                    summary: 'A practical guide on how to change your habits and get 1% better every day.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book2.png',
                    title: 'Deep Work',
                    author: 'Cal Newport',
                    rating: 4.7,
                    reviews: 150,
                    summary: 'Rules for focused success in a distracted world.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book3.png',
                    title: 'The 7 Habits of Highly Effective People',
                    author: 'Stephen R. Covey',
                    rating: 4.8,
                    reviews: 200,
                    summary: 'Powerful lessons in personal change.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book4.png',
                    title: 'The Happiness Advantage',
                    author: 'Shawn Achor',
                    rating: 4.6,
                    reviews: 120,
                    summary: 'How a happy brain fuels success and performance.',
                  ),
                ],
              ),
            ),
            SectionTitle(title: 'Your Favourites', showViewAll: true),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:[
                  BookDetailContainer(
                    imagePath: 'assets/images/book5.png',
                    title: 'Sapiens',
                    author: 'Yuval Noah Harari',
                    rating: 4.9,
                    reviews: 250,
                    summary: 'A brief history of humankind.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book6.png',
                    title: 'Educated',
                    author: 'Tara Westover',
                    rating: 4.8,
                    reviews: 180,
                    summary: 'A memoir about growing up in a strict family.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book7.png',
                    title: 'The Subtle Art of Not Giving a F*ck',
                    author: 'Mark Manson',
                    rating: 4.7,
                    reviews: 300,
                    summary: 'A counterintuitive approach to living a good life.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book8.png',
                    title: 'Becoming',
                    author: 'Michelle Obama',
                    rating: 4.8,
                    reviews: 220,
                    summary: 'A powerful memoir of the former First Lady.',
                  ),
                ],
              ),
            ),
            SectionTitle(title: "Top Rated"),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection:Axis.horizontal,
                children: [
                  BookDetailContainer(
                    imagePath: 'assets/images/book9.png',
                    title: 'To Kill a Mockingbird',
                    author: 'Harper Lee',
                    rating: 4.8,
                    reviews: 300,
                    summary: 'A classic novel exploring racial injustice and moral growth in the American South.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book10.png',
                    title: '1984',
                    author: 'George Orwell',
                    rating: 4.7,
                    reviews: 280,
                    summary: 'A dystopian novel about totalitarianism, surveillance, and individuality.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book11.png',
                    title: 'The Great Gatsby',
                    author: 'F. Scott Fitzgerald',
                    rating: 4.6,
                    reviews: 270,
                    summary: 'A tale of love, ambition, and the American Dream in the Roaring Twenties.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book12.png',
                    title: 'Pride and Prejudice',
                    author: 'Jane Austen',
                    rating: 4.8,
                    reviews: 320,
                    summary: 'A timeless romance and social commentary set in 19th-century England.',
                  ),
                ],
              ),

            ),
            SectionTitle(title:"New",showViewAll: true,),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BookDetailContainer(
                    imagePath: 'assets/images/book13.png',
                    title: 'Sapiens: A Brief History of Humankind',
                    author: 'Yuval Noah Harari',
                    rating: 4.9,
                    reviews: 250,
                    summary: 'Explores the history of humanity from the Stone Age to the modern era.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book14.png',
                    title: 'Becoming',
                    author: 'Michelle Obama',
                    rating: 4.8,
                    reviews: 400,
                    summary: 'A memoir by the former First Lady of the United States, sharing her personal and professional journey.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book15.png',
                    title: 'The Diary of a Young Girl',
                    author: 'Anne Frank',
                    rating: 4.9,
                    reviews: 500,
                    summary: 'A poignant account of a Jewish girl’s life in hiding during World War II.',
                  ),
                ],
              ),
            ),
            SectionTitle(title: "Free"),
            SizedBox(
              height:180 ,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  BookDetailContainer(
                    imagePath: 'assets/images/book16.png',
                    title: 'The Lord of the Rings',
                    author: 'J.R.R. Tolkien',
                    rating: 4.9,
                    reviews: 600,
                    summary: 'An epic fantasy trilogy about the quest to destroy a powerful ring and save Middle-earth.',
                  ),
                  SizedBox(width: 10),
                  BookDetailContainer(
                    imagePath: 'assets/images/book17.png',
                    title: 'Dune',
                    author: 'Frank Herbert',
                    rating: 4.7,
                    reviews: 450,
                    summary: 'A science fiction masterpiece set in a distant future with political intrigue and desert planets.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book18.png',
                    title: 'The Night Circus',
                    author: 'Erin Morgenstern',
                    rating: 4.6,
                    reviews: 300,
                    summary: 'A magical story about a mysterious circus and a competition between two young illusionists.',
                  ),
                  SizedBox(width: 10,),
                  BookDetailContainer(
                    imagePath: 'assets/images/book19.png',
                    title: 'Where the Crawdads Sing',
                    author: 'Delia Owens',
                    rating: 4.8,
                    reviews: 400,
                    summary: 'A blend of mystery, romance, and nature, following the life of a girl raised in the marshes of North Carolina.',
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
