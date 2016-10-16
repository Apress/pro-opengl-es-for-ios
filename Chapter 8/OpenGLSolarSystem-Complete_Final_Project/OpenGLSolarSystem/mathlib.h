// mathlib.h
// 
// Copyright (C) 2001, Chris Laurel <claurel@shatters.net>
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.

#ifndef _MATHLIB_H_
#define _MATHLIB_H_

#include <cmath>
#include <stdlib.h>

#define PI_ 3.14159265358979323846
//#define TWO_PI 6.28318530717958647692

template<class T> class Math
{
public:
    static inline void sincos(T, T&, T&);
    static inline T frand();
    static inline T sfrand();
    static inline T lerp(T t, T a, T b);
    static inline T clamp(T t);

private:
    // This class is static and should not be instantiated
    Math() {};
};


typedef Math<float> Mathf;
typedef Math<double> Mathd;


template<class T> T degToRad(T d)
{
    return d / 180 * static_cast<T>(PI_);
}

template<class T> T radToDeg(T r)
{
    return r * 180 / static_cast<T>(PI_);
}

template<class T> T abs(T x)
{
    return (x < 0) ? -x : x;
}

template<class T> T square(T x)
{
    return x * x;
}

template<class T> T cube(T x)
{
    return x * x * x;
}

template<class T> T clamp(T x)
{
    if (x < 0)
        return 0;
    else if (x > 1)
        return 1;
    else
        return x;
}

template<class T> int sign(T x)
{
    if (x < 0)
        return -1;
    else if (x > 0)
        return 1;
    else
        return 0;
}

// This function is like fmod except that it always returns
// a positive value in the range [ 0, y )
template<class T> T pfmod(T x, T y)
{
    int quotient = (int) abs(x / y);
    if (x < 0.0)
        return x + (quotient + 1) * y;
    else
        return x - quotient * y;
}

template<class T> T circleArea(T r)
{
    return (T) PI_ * r * r;
}

template<class T> T sphereArea(T r)
{
    return 4 * (T) PI_ * r * r;
}

template<class T> void Math<T>::sincos(T angle, T& s, T& c)
{
    s = (T) sin(angle);
    c = (T) cos(angle);
}


// return a random float in [0, 1]
template<class T> T Math<T>::frand()
{
    return (T) (rand() & 0x7fff) / (T) 32767;
}


// return a random float in [-1, 1]
template<class T> T Math<T>::sfrand()
{
    return (T) (rand() & 0x7fff) / (T) 32767 * 2 - 1;
}


template<class T> T Math<T>::lerp(T t, T a, T b)
{
    return a + t * (b - a);
}


// return t clamped to [0, 1]
template<class T> T Math<T>::clamp(T t)
{
    if (t < 0)
        return 0;
    else if (t > 1)
        return 1;
    else
        return t;
}

//vector stuff




#include <cmath>


//template<class T> class Point3;

template<class T> class Vector3
{
public:
    inline Vector3();
    inline Vector3(const Vector3<T>&);
    inline Vector3(T, T, T);
    
    inline T& operator[](int) const;
    inline Vector3& operator+=(const Vector3<T>&);
    inline Vector3& operator-=(const Vector3<T>&);
    inline Vector3& operator*=(T);
    
    inline Vector3 operator-();
    inline Vector3 operator+();
    
    inline T length() const;
    inline T lengthSquared() const;
    inline void normalize();
    
    T x, y, z;
};

template<class T> class Point3
{
public:
    inline Point3();
    inline Point3(const Point3&);
    inline Point3(T, T, T);
    
    inline T& operator[](int) const;
    inline Point3& operator+=(const Vector3<T>&);
    inline Point3& operator-=(const Vector3<T>&);
    inline Point3& operator-=(const Point3<T>&);
    inline Point3& operator+=(const Point3<T>&);
    inline Point3& operator*=(T);
    //	inline Point3& operator=(const Point3<T>&);
    
    inline T distanceTo(const Point3&) const;
    inline T distanceToSquared(const Point3&) const;
    inline T distanceFromOrigin() const;
    inline T distanceFromOriginSquared() const;
    
    T x, y, z;
};


template<class T> class Point2;

template<class T> class Vector2
{
public:
    inline Vector2();
    inline Vector2(T, T);
    
    T x, y;
};

template<class T> class Point2
{
public:
    inline Point2();
    inline Point2(T, T);
    
    T x, y;
};


template<class T> class Vector4
{
public:
    inline Vector4();
    inline Vector4(T, T, T, T);
    
    inline T& operator[](int) const;
    inline Vector4& operator+=(const Vector4&);
    inline Vector4& operator-=(const Vector4&);
    inline Vector4& operator*=(T);
    
    inline Vector4 operator-();
    inline Vector4 operator+();
    
    T x, y, z, w;
};


template<class T> class Matrix4
{
public:
    Matrix4();
    Matrix4(const Vector4<T>&, const Vector4<T>&,
            const Vector4<T>&, const Vector4<T>&);
    Matrix4(const Matrix4<T>& m);
    
    inline const Vector4<T>& operator[](int) const;
    inline Vector4<T> row(int) const;
    inline Vector4<T> column(int) const;
    
    static Matrix4<T> identity();
    static Matrix4<T> translation(const Point3<T>&);
    static Matrix4<T> translation(const Vector3<T>&);
    static Matrix4<T> rotation(const Vector3<T>&, T);
    static Matrix4<T> xrotation(T);
    static Matrix4<T> yrotation(T);
    static Matrix4<T> zrotation(T);
    static Matrix4<T> scaling(const Vector3<T>&);
    static Matrix4<T> scaling(T);
    
    void translate(const Point3<T>&);
    
    Matrix4<T> transpose() const;
    Matrix4<T> inverse() const;
    
    Vector4<T> r[4];
};


template<class T> class Matrix3
{
public:
    Matrix3();
    Matrix3(const Vector3<T>&, const Vector3<T>&, const Vector3<T>&);
    template<class U> Matrix3(const Matrix3<U>&);
    
    static Matrix3<T> xrotation(T);
    static Matrix3<T> yrotation(T);
    static Matrix3<T> zrotation(T);
    
    inline const Vector3<T>& operator[](int) const;
    inline Vector3<T> row(int) const;
    inline Vector3<T> column(int) const;
    
    inline Matrix3& operator*=(T);
    
    static Matrix3<T> identity();
    
    Matrix3<T> transpose() const;
    Matrix3<T> inverse() const;
    T determinant() const;
    
    //    template<class U> operator Matrix3<U>() const;
    
    Vector3<T> r[3];
};


typedef Vector3<float>   Vec3f;
typedef Vector3<double>  Vec3d;
typedef Point3<float>    Point3f;
typedef Point3<double>   Point3d;
typedef Vector2<float>   Vec2f;
typedef Point2<float>    Point2f;
typedef Vector4<float>   Vec4f;
typedef Vector4<double>  Vec4d;
typedef Matrix4<float>   Mat4f;
typedef Matrix4<double>  Mat4d;
typedef Matrix3<float>   Mat3f;
typedef Matrix3<double>  Mat3d;


//**** Vector3 constructors

template<class T> Vector3<T>::Vector3() : x(0), y(0), z(0)
{
}

template<class T> Vector3<T>::Vector3(const Vector3<T>& v) :
x(v.x), y(v.y), z(v.z)
{
}

template<class T> Vector3<T>::Vector3(T _x, T _y, T _z) : x(_x), y(_y), z(_z)
{
}


//**** Vector3 operators

template<class T> T& Vector3<T>::operator[](int n) const
{
    // Not portable--I'll write a new version when I try to compile on a
    // platform where it bombs.
    return ((T*) this)[n];
}

template<class T> Vector3<T>& Vector3<T>::operator+=(const Vector3<T>& a)
{
    x += a.x; y += a.y; z += a.z;
    return *this;
}

template<class T> Vector3<T>& Vector3<T>::operator-=(const Vector3<T>& a)
{
    x -= a.x; y -= a.y; z -= a.z;
    return *this;
}

template<class T> Vector3<T>& Vector3<T>::operator*=(T s)
{
    x *= s; y *= s; z *= s;
    return *this;
}

template<class T> Vector3<T> Vector3<T>::operator-()
{
    return Vector3<T>(-x, -y, -z);
}

template<class T> Vector3<T> Vector3<T>::operator+()
{
    return *this;
}


template<class T> Vector3<T> operator+(const Vector3<T>& a, const Vector3<T>& b)
{
    return Vector3<T>(a.x + b.x, a.y + b.y, a.z + b.z);
}

template<class T> Vector3<T> operator-(const Vector3<T>& a, const Vector3<T>& b)
{
    return Vector3<T>(a.x - b.x, a.y - b.y, a.z - b.z);
}

template<class T> Vector3<T> operator*(T s, const Vector3<T>& v)
{
    return Vector3<T>(s * v.x, s * v.y, s * v.z);
}

template<class T> Vector3<T> operator*(const Vector3<T>& v, T s)
{
    return Vector3<T>(s * v.x, s * v.y, s * v.z);
}

// dot product
template<class T> T operator*(const Vector3<T>& a, const Vector3<T>& b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

// cross product
template<class T> Vector3<T> operator^(const Vector3<T>& a, const Vector3<T>& b)
{
    return Vector3<T>(a.y * b.z - a.z * b.y,
                      a.z * b.x - a.x * b.z,
                      a.x * b.y - a.y * b.x);
}

template<class T> bool operator==(const Vector3<T>& a, const Vector3<T>& b)
{
    return a.x == b.x && a.y == b.y && a.z == b.z;
}

template<class T> bool operator!=(const Vector3<T>& a, const Vector3<T>& b)
{
    return a.x != b.x || a.y != b.y || a.z != b.z;
}

template<class T> Vector3<T> operator/(const Vector3<T>& v, T s)
{
    T is = 1 / s;
    return Vector3<T>(is * v.x, is * v.y, is * v.z);
}

template<class T> T dot(const Vector3<T>& a, const Vector3<T>& b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

template<class T> Vector3<T> cross(const Vector3<T>& a, const Vector3<T>& b)
{
    return Vector3<T>(a.y * b.z - a.z * b.y,
                      a.z * b.x - a.x * b.z,
                      a.x * b.y - a.y * b.x);
}

template<class T> T Vector3<T>::length() const
{
    return (T) sqrt(x * x + y * y + z * z);
}

template<class T> T Vector3<T>::lengthSquared() const
{
    return x * x + y * y + z * z;
}

template<class T> void Vector3<T>::normalize()
{
    T s = 1 / (T) sqrt(x * x + y * y + z * z);
    x *= s;
    y *= s;
    z *= s;
}


//**** Point3 constructors

template<class T> Point3<T>::Point3() : x(0), y(0), z(0)
{
}

template<class T> Point3<T>::Point3(const Point3<T>& p) :
x(p.x), y(p.y), z(p.z)
{
}

template<class T> Point3<T>::Point3(T _x, T _y, T _z) : x(_x), y(_y), z(_z)
{
}


//**** Point3 operators

template<class T> T& Point3<T>::operator[](int n) const
{
    // Not portable--I'll write a new version when I try to compile on a
    // platform where it bombs.
    return ((T*) this)[n];
}

template<class T> Vector3<T> operator-(const Point3<T>& a, const Point3<T>& b)
{
    return Vector3<T>(a.x - b.x, a.y - b.y, a.z - b.z);
}

template<class T> Point3<T>& Point3<T>::operator+=(const Vector3<T>& v)
{
    x += v.x; y += v.y; z += v.z;
    return *this;
}

template<class T> Point3<T>& Point3<T>::operator+=(const Point3<T>& v)
{
    x += v.x; y += v.y; z += v.z;
    return *this;
}

template<class T> Point3<T>& Point3<T>::operator-=(const Vector3<T>& v)
{
    x -= v.x; y -= v.y; z -= v.z;
    return *this;
}

template<class T> Point3<T>& Point3<T>::operator-=(const Point3<T>& v)
{
    x -= v.x; y -= v.y; z -= v.z;
    return *this;
}

template<class T> Point3<T>& Point3<T>::operator*=(T s)
{
    x *= s; y *= s; z *= s;
    return *this;
}

template<class T> bool operator==(const Point3<T>& a, const Point3<T>& b)
{
    return a.x == b.x && a.y == b.y && a.z == b.z;
}

template<class T> bool operator!=(const Point3<T>& a, const Point3<T>& b)
{
    return a.x != b.x || a.y != b.y || a.z != b.z;
}

template<class T> Point3<T> operator+(const Point3<T>& p, const Vector3<T>& v)
{
    return Point3<T>(p.x + v.x, p.y + v.y, p.z + v.z);
}

template<class T> Point3<T> operator-(const Point3<T>& p, const Vector3<T>& v)
{
    return Point3<T>(p.x - v.x, p.y - v.y, p.z - v.z);
}
/*
 template<class T> Point3<T>& Point3<T>::operator=(const Point3<T>& p)
 {
 
 x=p.x;
 y=p.y;
 z=p.z;
 
 return *this;
 }
 */
// Naughty naughty . . .  remove these since they aren't proper
// point methods--changing the implicit homogenous coordinate isn't
// allowed.
template<class T> Point3<T> operator*(const Point3<T>& p, T s)
{
    return Point3<T>(p.x * s, p.y * s, p.z * s);
}

template<class T> Point3<T> operator*(T s, const Point3<T>& p)
{
    return Point3<T>(p.x * s, p.y * s, p.z * s);
}


//**** Point3 methods

template<class T> T Point3<T>::distanceTo(const Point3& p) const
{
    return (T) sqrt((p.x - x) * (p.x - x) +
                    (p.y - y) * (p.y - y) +
                    (p.z - z) * (p.z - z));
}

template<class T> T Point3<T>::distanceToSquared(const Point3& p) const
{
    return ((p.x - x) * (p.x - x) +
            (p.y - y) * (p.y - y) +
            (p.z - z) * (p.z - z));
}

template<class T> T Point3<T>::distanceFromOrigin() const
{
    return (T) sqrt(x * x + y * y + z * z);
}

template<class T> T Point3<T>::distanceFromOriginSquared() const
{
    return x * x + y * y + z * z;
}



//**** Vector2 constructors
template<class T> Vector2<T>::Vector2() : x(0), y(0)
{
}

template<class T> Vector2<T>::Vector2(T _x, T _y) : x(_x), y(_y)
{
}


//**** Vector2 operators
template<class T> bool operator==(const Vector2<T>& a, const Vector2<T>& b)
{
    return a.x == b.x && a.y == b.y;
}

template<class T> bool operator!=(const Vector2<T>& a, const Vector2<T>& b)
{
    return a.x != b.x || a.y != b.y;
}


//**** Point2 constructors

template<class T> Point2<T>::Point2() : x(0), y(0)
{
}

template<class T> Point2<T>::Point2(T _x, T _y) : x(_x), y(_y)
{
}


//**** Point2 operators

template<class T> bool operator==(const Point2<T>& a, const Point2<T>& b)
{
    return a.x == b.x && a.y == b.y;
}

template<class T> bool operator!=(const Point2<T>& a, const Point2<T>& b)
{
    return a.x != b.x || a.y != b.y;
}


//**** Vector4 constructors

template<class T> Vector4<T>::Vector4() : x(0), y(0), z(0), w(0)
{
}

template<class T> Vector4<T>::Vector4(T _x, T _y, T _z, T _w) :
x(_x), y(_y), z(_z), w(_w)
{
}


//**** Vector4 operators

template<class T> T& Vector4<T>::operator[](int n) const
{
    // Not portable--I'll write a new version when I try to compile on a
    // platform where it bombs.
    return ((T*) this)[n];
}

template<class T> bool operator==(const Vector4<T>& a, const Vector4<T>& b)
{
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
}

template<class T> bool operator!=(const Vector4<T>& a, const Vector4<T>& b)
{
    return a.x != b.x || a.y != b.y || a.z != b.z || a.w != b.w;
}

template<class T> Vector4<T>& Vector4<T>::operator+=(const Vector4<T>& a)
{
    x += a.x; y += a.y; z += a.z; w += a.w;
    return *this;
}

template<class T> Vector4<T>& Vector4<T>::operator-=(const Vector4<T>& a)
{
    x -= a.x; y -= a.y; z -= a.z; w -= a.w;
    return *this;
}

template<class T> Vector4<T>& Vector4<T>::operator*=(T s)
{
    x *= s; y *= s; z *= s; w *= s;
    return *this;
}

template<class T> Vector4<T> Vector4<T>::operator-()
{
    return Vector4<T>(-x, -y, -z, -w);
}

template<class T> Vector4<T> Vector4<T>::operator+()
{
    return *this;
}

template<class T> Vector4<T> operator+(const Vector4<T>& a, const Vector4<T>& b)
{
    return Vector4<T>(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w);
}

template<class T> Vector4<T> operator-(const Vector4<T>& a, const Vector4<T>& b)
{
    return Vector4<T>(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w);
}

template<class T> Vector4<T> operator*(T s, const Vector4<T>& v)
{
    return Vector4<T>(s * v.x, s * v.y, s * v.z, s * v.w);
}

template<class T> Vector4<T> operator*(const Vector4<T>& v, T s)
{
    return Vector4<T>(s * v.x, s * v.y, s * v.z, s * v.w);
}

// dot product
template<class T> T operator*(const Vector4<T>& a, const Vector4<T>& b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}

template<class T> T dot(const Vector4<T>& a, const Vector4<T>& b)
{
    return a * b;
}



//**** Matrix3 constructors

template<class T> Matrix3<T>::Matrix3()
{
    r[0] = Vector3<T>(0, 0, 0);
    r[1] = Vector3<T>(0, 0, 0);
    r[2] = Vector3<T>(0, 0, 0);
}


template<class T> Matrix3<T>::Matrix3(const Vector3<T>& r0,
                                      const Vector3<T>& r1,
                                      const Vector3<T>& r2)
{
    r[0] = r0;
    r[1] = r1;
    r[2] = r2;
}


#if 0
template<class T, class U> Matrix3<T>::Matrix3(const Matrix3<U>& m)
{
#if 0
    r[0] = m.r[0];
    r[1] = m.r[1];
    r[2] = m.r[2];
#endif
    r[0].x = m.r[0].x; r[0].y = m.r[0].y; r[0].z = m.r[0].z;
    r[1].x = m.r[1].x; r[1].y = m.r[1].y; r[1].z = m.r[1].z;
    r[2].x = m.r[2].x; r[2].y = m.r[2].y; r[2].z = m.r[2].z;
}
#endif


//**** Matrix3 operators

template<class T> const Vector3<T>& Matrix3<T>::operator[](int n) const
{
    //    return const_cast<Vector3<T>&>(r[n]);
    return r[n];
}

template<class T> Vector3<T> Matrix3<T>::row(int n) const
{
    return r[n];
}

template<class T> Vector3<T> Matrix3<T>::column(int n) const
{
    return Vector3<T>(r[0][n], r[1][n], r[2][n]);
}

template<class T> Matrix3<T>& Matrix3<T>::operator*=(T s)
{
    r[0] *= s;
    r[1] *= s;
    r[2] *= s;
    return *this;
}


// pre-multiply column vector by a 3x3 matrix
template<class T> Vector3<T> operator*(const Matrix3<T>& m, const Vector3<T>& v)
{
    return Vector3<T>(m.r[0].x * v.x + m.r[0].y * v.y + m.r[0].z * v.z,
					  m.r[1].x * v.x + m.r[1].y * v.y + m.r[1].z * v.z,
		              m.r[2].x * v.x + m.r[2].y * v.y + m.r[2].z * v.z);
}


// post-multiply row vector by a 3x3 matrix
template<class T> Vector3<T> operator*(const Vector3<T>& v, const Matrix3<T>& m)
{
    return Vector3<T>(m.r[0].x * v.x + m.r[1].x * v.y + m.r[2].x * v.z,
                      m.r[0].y * v.x + m.r[1].y * v.y + m.r[2].y * v.z,
                      m.r[0].z * v.x + m.r[1].z * v.y + m.r[2].z * v.z);
}


// pre-multiply column point by a 3x3 matrix
template<class T> Point3<T> operator*(const Matrix3<T>& m, const Point3<T>& p)
{
    return Point3<T>(m.r[0].x * p.x + m.r[0].y * p.y + m.r[0].z * p.z,
                     m.r[1].x * p.x + m.r[1].y * p.y + m.r[1].z * p.z,
                     m.r[2].x * p.x + m.r[2].y * p.y + m.r[2].z * p.z);
}


// post-multiply row point by a 3x3 matrix
template<class T> Point3<T> operator*(const Point3<T>& p, const Matrix3<T>& m)
{
    return Point3<T>(m.r[0].x * p.x + m.r[1].x * p.y + m.r[2].x * p.z,
					 m.r[0].y * p.x + m.r[1].y * p.y + m.r[2].y * p.z,
					 m.r[0].z * p.x + m.r[1].z * p.y + m.r[2].z * p.z);
}


template<class T> Matrix3<T> operator*(const Matrix3<T>& a,
                                       const Matrix3<T>& b)
{
#define MATMUL(R, C) (a[R].x * b[0].C + a[R].y * b[1].C + a[R].z * b[2].C)
    return Matrix3<T>(Vector3<T>(MATMUL(0, x), MATMUL(0, y), MATMUL(0, z)),
                      Vector3<T>(MATMUL(1, x), MATMUL(1, y), MATMUL(1, z)),
                      Vector3<T>(MATMUL(2, x), MATMUL(2, y), MATMUL(2, z)));
#undef MATMUL
}


template<class T> Matrix3<T> operator+(const Matrix3<T>& a,
                                       const Matrix3<T>& b)
{
    return Matrix3<T>(a.r[0] + b.r[0],
                      a.r[1] + b.r[1],
                      a.r[2] + b.r[2]);
}


template<class T> Matrix3<T> Matrix3<T>::identity()
{
    return Matrix3<T>(Vector3<T>(1, 0, 0),
                      Vector3<T>(0, 1, 0),
                      Vector3<T>(0, 0, 1));
}


template<class T> Matrix3<T> Matrix3<T>::transpose() const
{
    return Matrix3<T>(Vector3<T>(r[0].x, r[1].x, r[2].x),
                      Vector3<T>(r[0].y, r[1].y, r[2].y),
                      Vector3<T>(r[0].z, r[1].z, r[2].z));
}


template<class T> T det2x2(T a, T b, T c, T d)
{
    return a * d - b * c;
}

template<class T> T Matrix3<T>::determinant() const
{
    return (r[0].x * r[1].y * r[2].z +
            r[0].y * r[1].z * r[2].x +
            r[0].z * r[1].x * r[2].y -
            r[0].z * r[1].y * r[2].x -
            r[0].x * r[1].z * r[2].y -
            r[0].y * r[1].x * r[2].z);
}


template<class T> Matrix3<T> Matrix3<T>::inverse() const
{
    Matrix3<T> adjoint;
    
    // Just use Cramer's rule for now . . .
    adjoint.r[0].x =  det2x2(r[1].y, r[1].z, r[2].y, r[2].z);
    adjoint.r[0].y = -det2x2(r[1].x, r[1].z, r[2].x, r[2].z);
    adjoint.r[0].z =  det2x2(r[1].x, r[1].y, r[2].x, r[2].y);
    adjoint.r[1].x = -det2x2(r[0].y, r[0].z, r[2].y, r[2].z);
    adjoint.r[1].y =  det2x2(r[0].x, r[0].z, r[2].x, r[2].z);
    adjoint.r[1].z = -det2x2(r[0].x, r[0].y, r[2].x, r[2].y);
    adjoint.r[2].x =  det2x2(r[0].y, r[0].z, r[1].y, r[1].z);
    adjoint.r[2].y = -det2x2(r[0].x, r[0].z, r[1].x, r[1].z);
    adjoint.r[2].z =  det2x2(r[0].x, r[0].y, r[1].x, r[1].y);
    adjoint *= 1 / determinant();
    
    return adjoint;
}


template<class T> Matrix3<T> Matrix3<T>::xrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix3<T>(Vector3<T>(1, 0, 0),
                      Vector3<T>(0, c, -s),
                      Vector3<T>(0, s, c));
}


template<class T> Matrix3<T> Matrix3<T>::yrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix3<T>(Vector3<T>(c, 0, s),
                      Vector3<T>(0, 1, 0),
                      Vector3<T>(-s, 0, c));
}


template<class T> Matrix3<T> Matrix3<T>::zrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix3<T>(Vector3<T>(c, -s, 0),
                      Vector3<T>(s, c, 0),
                      Vector3<T>(0, 0, 1));
}


/***********************************************
 **
 **  Matrix4 methods
 **
 ***********************************************/

template<class T> Matrix4<T>::Matrix4()
{
    r[0] = Vector4<T>(0, 0, 0, 0);
    r[1] = Vector4<T>(0, 0, 0, 0);
    r[2] = Vector4<T>(0, 0, 0, 0);
    r[3] = Vector4<T>(0, 0, 0, 0);
}


template<class T> Matrix4<T>::Matrix4(const Vector4<T>& v0,
                                      const Vector4<T>& v1,
                                      const Vector4<T>& v2,
                                      const Vector4<T>& v3)
{
    r[0] = v0;
    r[1] = v1;
    r[2] = v2;
    r[3] = v3;
}


template<class T> Matrix4<T>::Matrix4(const Matrix4<T>& m)
{
    r[0] = m.r[0];
    r[1] = m.r[1];
    r[2] = m.r[2];
    r[3] = m.r[3];
}


template<class T> const Vector4<T>& Matrix4<T>::operator[](int n) const
{
    return r[n];
    //    return const_cast<Vector4<T>&>(r[n]);
}

template<class T> Vector4<T> Matrix4<T>::row(int n) const
{
    return r[n];
}

template<class T> Vector4<T> Matrix4<T>::column(int n) const
{
    return Vector4<T>(r[0][n], r[1][n], r[2][n], r[3][n]);
}


template<class T> Matrix4<T> Matrix4<T>::identity()
{
    return Matrix4<T>(Vector4<T>(1, 0, 0, 0),
                      Vector4<T>(0, 1, 0, 0),
                      Vector4<T>(0, 0, 1, 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::translation(const Point3<T>& p)
{
    return Matrix4<T>(Vector4<T>(1, 0, 0, 0),
                      Vector4<T>(0, 1, 0, 0),
                      Vector4<T>(0, 0, 1, 0),
                      Vector4<T>(p.x, p.y, p.z, 1));
}


template<class T> Matrix4<T> Matrix4<T>::translation(const Vector3<T>& v)
{
    return Matrix4<T>(Vector4<T>(1, 0, 0, 0),
                      Vector4<T>(0, 1, 0, 0),
                      Vector4<T>(0, 0, 1, 0),
                      Vector4<T>(v.x, v.y, v.z, 1));
}


template<class T> void Matrix4<T>::translate(const Point3<T>& p)
{
    r[3].x += p.x;
    r[3].y += p.y;
    r[3].z += p.z;
}


template<class T> Matrix4<T> Matrix4<T>::rotation(const Vector3<T>& axis,
                                                  T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    T t = 1 - c;
    
    return Matrix4<T>(Vector4<T>(t * axis.x * axis.x + c,
                                 t * axis.x * axis.y - s * axis.z,
                                 t * axis.x * axis.z + s * axis.y,
                                 0),
                      Vector4<T>(t * axis.x * axis.y + s * axis.z,
                                 t * axis.y * axis.y + c,
                                 t * axis.y * axis.z - s * axis.x,
                                 0),
                      Vector4<T>(t * axis.x * axis.z - s * axis.y,
                                 t * axis.y * axis.z + s * axis.x,
                                 t * axis.z * axis.z + c,
                                 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::xrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix4<T>(Vector4<T>(1, 0, 0, 0),
                      Vector4<T>(0, c, -s, 0),
                      Vector4<T>(0, s, c, 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::yrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix4<T>(Vector4<T>(c, 0, s, 0),
                      Vector4<T>(0, 1, 0, 0),
                      Vector4<T>(-s, 0, c, 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::zrotation(T angle)
{
    T c = (T) cos(angle);
    T s = (T) sin(angle);
    
    return Matrix4<T>(Vector4<T>(c, -s, 0, 0),
                      Vector4<T>(s, c, 0, 0),
                      Vector4<T>(0, 0, 1, 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::scaling(const Vector3<T>& scale)
{
    return Matrix4<T>(Vector4<T>(scale.x, 0, 0, 0),
                      Vector4<T>(0, scale.y, 0, 0),
                      Vector4<T>(0, 0, scale.z, 0),
                      Vector4<T>(0, 0, 0, 1));
}


template<class T> Matrix4<T> Matrix4<T>::scaling(T scale)
{
    return scaling(Vector3<T>(scale, scale, scale));
}


// multiply column vector by a 4x4 matrix
template<class T> Vector3<T> operator*(const Matrix4<T>& m, const Vector3<T>& v)
{
    return Vector3<T>(m.r[0].x * v.x + m.r[0].y * v.y + m.r[0].z * v.z,
                      m.r[1].x * v.x + m.r[1].y * v.y + m.r[1].z * v.z,
                      m.r[2].x * v.x + m.r[2].y * v.y + m.r[2].z * v.z);
}

// multiply row vector by a 4x4 matrix
template<class T> Vector3<T> operator*(const Vector3<T>& v, const Matrix4<T>& m)
{
    return Vector3<T>(m.r[0].x * v.x + m.r[1].x * v.y + m.r[2].x * v.z,
                      m.r[0].y * v.x + m.r[1].y * v.y + m.r[2].y * v.z,
                      m.r[0].z * v.x + m.r[1].z * v.y + m.r[2].z * v.z);
}

// multiply column point by a 4x4 matrix; no projection is performed
template<class T> Point3<T> operator*(const Matrix4<T>& m, const Point3<T>& p)
{
    return Point3<T>(m.r[0].x * p.x + m.r[0].y * p.y + m.r[0].z * p.z + m.r[0].w,
                     m.r[1].x * p.x + m.r[1].y * p.y + m.r[1].z * p.z + m.r[1].w,
                     m.r[2].x * p.x + m.r[2].y * p.y + m.r[2].z * p.z + m.r[2].w);
}

// multiply row point by a 4x4 matrix; no projection is performed
template<class T> Point3<T> operator*(const Point3<T>& p, const Matrix4<T>& m)
{
    return Point3<T>(m.r[0].x * p.x + m.r[1].x * p.y + m.r[2].x * p.z + m.r[3].x,
                     m.r[0].y * p.x + m.r[1].y * p.y + m.r[2].y * p.z + m.r[3].y,
                     m.r[0].z * p.x + m.r[1].z * p.y + m.r[2].z * p.z + m.r[3].z);
}

// multiply column vector by a 4x4 matrix
template<class T> Vector4<T> operator*(const Matrix4<T>& m, const Vector4<T>& v)
{
    return Vector4<T>(m.r[0].x * v.x + m.r[0].y * v.y + m.r[0].z * v.z + m.r[0].w * v.w,
                      m.r[1].x * v.x + m.r[1].y * v.y + m.r[1].z * v.z + m.r[1].w * v.w,
                      m.r[2].x * v.x + m.r[2].y * v.y + m.r[2].z * v.z + m.r[2].w * v.w,
                      m.r[3].x * v.x + m.r[3].y * v.y + m.r[3].z * v.z + m.r[3].w * v.w);
}

// multiply row vector by a 4x4 matrix
template<class T> Vector4<T> operator*(const Vector4<T>& v, const Matrix4<T>& m)
{
    return Vector4<T>(m.r[0].x * v.x + m.r[1].x * v.y + m.r[2].x * v.z + m.r[3].x * v.w,
                      m.r[0].y * v.x + m.r[1].y * v.y + m.r[2].y * v.z + m.r[3].y * v.w,
                      m.r[0].z * v.x + m.r[1].z * v.y + m.r[2].z * v.z + m.r[3].z * v.w,
                      m.r[0].w * v.x + m.r[1].w * v.y + m.r[2].w * v.z + m.r[3].w * v.w);
}



template<class T> Matrix4<T> Matrix4<T>::transpose() const
{
    return Matrix4<T>(Vector4<T>(r[0].x, r[1].x, r[2].x, r[3].x),
                      Vector4<T>(r[0].y, r[1].y, r[2].y, r[3].y),
                      Vector4<T>(r[0].z, r[1].z, r[2].z, r[3].z),
                      Vector4<T>(r[0].w, r[1].w, r[2].w, r[3].w));
}


template<class T> Matrix4<T> operator*(const Matrix4<T>& a,
                                       const Matrix4<T>& b)
{
#define MATMUL(R, C) (a[R].x * b[0].C + a[R].y * b[1].C + a[R].z * b[2].C + a[R].w * b[3].C)
    return Matrix4<T>(Vector4<T>(MATMUL(0, x), MATMUL(0, y), MATMUL(0, z), MATMUL(0, w)),
                      Vector4<T>(MATMUL(1, x), MATMUL(1, y), MATMUL(1, z), MATMUL(1, w)),
                      Vector4<T>(MATMUL(2, x), MATMUL(2, y), MATMUL(2, z), MATMUL(2, w)),
                      Vector4<T>(MATMUL(3, x), MATMUL(3, y), MATMUL(3, z), MATMUL(3, w)));
#undef MATMUL
}


template<class T> Matrix4<T> operator+(const Matrix4<T>& a, const Matrix4<T>& b)
{
    return Matrix4<T>(a[0] + b[0], a[1] + b[1], a[2] + b[2], a[3] + b[3]);
}


// Compute inverse using Gauss-Jordan elimination; caller is responsible
// for ensuring that the matrix isn't singular.
template<class T> Matrix4<T> Matrix4<T>::inverse() const
{
    Matrix4<T> a(*this);
    Matrix4<T> b(Matrix4<T>::identity());
    int i, j;
    int p;
    
    for (j = 0; j < 4; j++)
    {
        p = j;
        for (i = j + 1; i < 4; i++)
        {
            if (fabs(a.r[i][j]) > fabs(a.r[p][j]))
                p = i;
        }
        
        // Swap rows p and j
        Vector4<T> t = a.r[p];
        a.r[p] = a.r[j];
        a.r[j] = t;
        
        t = b.r[p];
        b.r[p] = b.r[j];
        b.r[j] = t;
        
        T s = a.r[j][j];  // if s == 0, the matrix is singular
        a.r[j] *= (1.0f / s);
        b.r[j] *= (1.0f / s);
        
        // Eliminate off-diagonal elements
        for (i = 0; i < 4; i++)
        {
            if (i != j)
            {
                b.r[i] -= a.r[i][j] * b.r[j];
                a.r[i] -= a.r[i][j] * a.r[j];
            }
        }
    }
    
    return b;
}

#ifndef PI
#define PI			3.141592654
#endif

template<class T> class Quaternion
{
public:
    inline Quaternion();
    inline Quaternion(const Quaternion<T>&);
    inline Quaternion(T);
    inline Quaternion(const Vector3<T>&);
    inline Quaternion(T, const Vector3<T>&);
    inline Quaternion(T, T, T, T);
    
    Quaternion(const Matrix3<T>&);
    
    inline Quaternion& operator+=(Quaternion);
    inline Quaternion& operator-=(Quaternion);
    inline Quaternion& operator*=(T);
    Quaternion& operator*=(Quaternion);
    
    inline Quaternion operator~();    // conjugate
    inline Quaternion operator-();
    inline Quaternion operator+();
    
    void setAxisAngle(Vector3<T> axis, T angle);
    
    void getAxisAngle(Vector3<T>& axis, T& angle) const;
    Matrix4<T> toMatrix4() const;
    Matrix3<T> toMatrix3() const;
    
    static Quaternion<T> slerp(Quaternion<T>, Quaternion<T>, T);
    
    void rotate(Vector3<T> axis, T angle);
    void xrotate(T angle);
    void yrotate(T angle);
    void zrotate(T angle);
    
    bool isPure() const;
    bool isReal() const;
    T normalize();
    
#if 0
    // This code is disabled until I can 
#ifndef BROKEN_FRIEND_TEMPLATES
    // This just rocks . . .  MSVC 6.0 doesn't parse this correctly,
    // so template friend functions need to be declared in the standard
    // conforming way for GNU C and a non-conforming way for MSVC.
    friend Quaternion<T> operator+ <>(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator- <>(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator* <>(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator* <>(T, Quaternion<T>);
    friend Quaternion<T> operator* <>(Vector3<T>, Quaternion<T>);
    
    friend bool operator== <>(Quaternion<T>, Quaternion<T>);
    friend bool operator!= <>(Quaternion<T>, Quaternion<T>);
    
    friend T real<>(Quaternion<T>);
    friend Vector3<T> imag<>(Quaternion<T>);
#else
    friend Quaternion<T> operator+(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator-(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator*(Quaternion<T>, Quaternion<T>);
    friend Quaternion<T> operator*(T, Quaternion<T>);
    friend Quaternion<T> operator*(Vector3<T>, Quaternion<T>);
    
    friend bool operator==(Quaternion<T>, Quaternion<T>);
    friend bool operator!=(Quaternion<T>, Quaternion<T>);
    
    friend T real(Quaternion<T>);
    friend Vector3<T> imag(Quaternion<T>);
#endif // BROKEN_FRIEND_TEMPLATES
    
#endif
    
    // Until friend templates are working . . .
    // private:
    T w, x, y, z;
};


typedef Quaternion<float> Quatf;
typedef Quaternion<double> Quatd;


template<class T> Quaternion<T>::Quaternion() : w(0), x(0), y(0), z(0)
{
}

template<class T> Quaternion<T>::Quaternion(const Quaternion<T>& q) :
w(q.w), x(q.x), y(q.y), z(q.z)
{
}

template<class T> Quaternion<T>::Quaternion(T re) :
w(re), x(0), y(0), z(0)
{
}

// Create a 'pure' quaternion
template<class T> Quaternion<T>::Quaternion(const Vector3<T>& im) :
w(0), x(im.x), y(im.y), z(im.z)
{
}

template<class T> Quaternion<T>::Quaternion(T re, const Vector3<T>& im) :
w(re), x(im.x), y(im.y), z(im.z)
{
}

template<class T> Quaternion<T>::Quaternion(T _w, T _x, T _y, T _z) :
w(_w), x(_x), y(_y), z(_z)
{
}

// Create a quaternion from a rotation matrix
template<class T> Quaternion<T>::Quaternion(const Matrix3<T>& m)
{
    T trace = m[0][0] + m[1][1] + m[2][2];
    T root;
    
    if (trace > 0)
    {
        root = (T) sqrt(trace + 1);
        w = (T) 0.5 * root;
        root = (T) 0.5 / root;
        x = (m[2][1] - m[1][2]) * root;
        y = (m[0][2] - m[2][0]) * root;
        z = (m[1][0] - m[0][1]) * root;
    }
    else
    {
        int i = 0;
        if (m[1][1] > m[i][i])
            i = 1;
        if (m[2][2] > m[i][i])
            i = 2;
        int j = (i == 2) ? 0 : i + 1;
        int k = (j == 2) ? 0 : j + 1;
        
        root = (T) sqrt(m[i][i] - m[j][j] - m[k][k] + 1.0);
        T* xyz[3] = { &x, &y, &z };
        *xyz[i] = (T) 0.5 * root;
        
		if(root!=0.0)
			root = (T) 0.5 / root;
        
        w = (m[k][j] - m[j][k]) * root;				//bug? rms 12/26/02
        
        //		w = (m[j][k] - m[k][j]) * root;
        *xyz[j] = (m[j][i] + m[i][j]) * root;
        *xyz[k] = (m[k][i] + m[i][k]) * root;
    }
}


template<class T> Quaternion<T>& Quaternion<T>::operator+=(Quaternion<T> a)
{
    x += a.x; y += a.y; z += a.z; w += a.w;
    return *this;
}

template<class T> Quaternion<T>& Quaternion<T>::operator-=(Quaternion<T> a)
{
    x -= a.x; y -= a.y; z -= a.z; w -= a.w;
    return *this;
}

template<class T> Quaternion<T>& Quaternion<T>::operator*=(Quaternion<T> q)
{
    *this = Quaternion<T>(w * q.w - x * q.x - y * q.y - z * q.z,
                          w * q.x + x * q.w + y * q.z - z * q.y,
                          w * q.y + y * q.w + z * q.x - x * q.z,
                          w * q.z + z * q.w + x * q.y - y * q.x);
    
    return *this;
}

template<class T> Quaternion<T>& Quaternion<T>::operator*=(T s)
{
    x *= s; y *= s; z *= s; w *= s;
    return *this;
}

// conjugate operator
template<class T> Quaternion<T> Quaternion<T>::operator~()
{
    return Quaternion<T>(w, -x, -y, -z);
}

template<class T> Quaternion<T> Quaternion<T>::operator-()
{
    return Quaternion<T>(-w, -x, -y, -z);
}

template<class T> Quaternion<T> Quaternion<T>::operator+()
{
    return *this;
}


template<class T> Quaternion<T> operator+(Quaternion<T> a, Quaternion<T> b)
{
    return Quaternion<T>(a.w + b.w, a.x + b.x, a.y + b.y, a.z + b.z);
}

template<class T> Quaternion<T> operator-(Quaternion<T> a, Quaternion<T> b)
{
    return Quaternion<T>(a.w - b.w, a.x - b.x, a.y - b.y, a.z - b.z);
}

template<class T> Quaternion<T> operator*(Quaternion<T> a, Quaternion<T> b)
{
    return Quaternion<T>(a.w * b.w - a.x * b.x - a.y * b.y - a.z * b.z,
                         a.w * b.x + a.x * b.w + a.y * b.z - a.z * b.y,
                         a.w * b.y + a.y * b.w + a.z * b.x - a.x * b.z,
                         a.w * b.z + a.z * b.w + a.x * b.y - a.y * b.x);
}

template<class T> Quaternion<T> operator*(T s, Quaternion<T> q)
{
    return Quaternion<T>(s * q.w, s * q.x, s * q.y, s * q.z);
}

template<class T> Quaternion<T> operator*(Quaternion<T> q, T s)
{
    return Quaternion<T>(s * q.w, s * q.x, s * q.y, s * q.z);
}

// equivalent to multiplying by the quaternion (0, v)
template<class T> Quaternion<T> operator*(Vector3<T> v, Quaternion<T> q)
{
    return Quaternion<T>(-v.x * q.x - v.y * q.y - v.z * q.z,
                         v.x * q.w + v.y * q.z - v.z * q.y,
                         v.y * q.w + v.z * q.x - v.x * q.z,
                         v.z * q.w + v.x * q.y - v.y * q.x);
}

template<class T> Quaternion<T> operator/(Quaternion<T> q, T s)
{
    return q * (1 / s);
}

template<class T> Quaternion<T> operator/(Quaternion<T> a, Quaternion<T> b)
{
    return a * (~b / abs(b));
}


template<class T> bool operator==(Quaternion<T> a, Quaternion<T> b)
{
    return a.x == b.x && a.y == b.y && a.z == b.z && a.w == b.w;
}

template<class T> bool operator!=(Quaternion<T> a, Quaternion<T> b)
{
    return a.x != b.x || a.y != b.y || a.z != b.z || a.w != b.w;
}


// elementary functions
template<class T> Quaternion<T> conjugate(Quaternion<T> q)
{
    return Quaternion<T>(q.w, -q.x, -q.y, -q.z);
}

template<class T> T norm(Quaternion<T> q)
{
    return q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w;
}

template<class T> T abs(Quaternion<T> q)
{
    return (T) sqrt(norm(q));
}

template<class T> Quaternion<T> exp(Quaternion<T> q)
{
    if (q.isReal())
    {
        return Quaternion<T>((T) exp(q.w));
    }
    else
    {
        T l = (T) sqrt(q.x * q.x + q.y * q.y + q.z * q.z);
        T s = (T) sin(l);
        T c = (T) cos(l);
        T e = (T) exp(q.w);
        T t = e * s / l;
        return Quaternion<T>(e * c, t * q.x, t * q.y, t * q.z);
    }
}

template<class T> Quaternion<T> log(Quaternion<T> q)
{
    if (q.isReal())
    {
        if (q.w > 0)
        {
            return Quaternion<T>((T) log(q.w));
        }
        else if (q.w < 0)
        {
            // The log of a negative purely real quaternion has
            // infinitely many values, all of the form (ln(-w), PI * I),
            // where I is any unit vector.  We arbitrarily choose an I
            // of (1, 0, 0) here and whereever else a similar choice is
            // necessary.  Geometrically, the set of roots is a sphere
            // of radius PI centered at ln(-w) on the real axis.
            return Quaternion<T>((T) log(-q.w), (T) PI, 0, 0);
        }
        else
        {
            // error . . . ln(0) not defined
            return Quaternion<T>(0);
        }
    }
    else
    {
        T l = (T) sqrt(q.x * q.x + q.y * q.y + q.z * q.z);
        T r = (T) sqrt(l * l + q.w * q.w);
        T theta = (T) atan2(l, q.w);
        T t = theta / l;
        return Quaternion<T>((T) log(r), t * q.x, t * q.y, t * q.z);
    }
}


template<class T> Quaternion<T> pow(Quaternion<T> q, T s)
{
    return exp(s * log(q));
}


template<class T> Quaternion<T> pow(Quaternion<T> q, Quaternion<T> p)
{
    return exp(p * log(q));
}


template<class T> Quaternion<T> sin(Quaternion<T> q)
{
    if (q.isReal())
    {
        return Quaternion<T>((T) sin(q.w));
    }
    else
    {
        T l = (T) sqrt(q.x * q.x + q.y * q.y + q.z * q.z);
        T m = q.w;
        T s = (T) sin(m);
        T c = (T) cos(m);
        T il = 1 / l;
        T e0 = (T) exp(-l);
        T e1 = (T) exp(l);
        
        T c0 = (T) -0.5 * e0 * il * c;
        T c1 = (T)  0.5 * e1 * il * c;
        
        return Quaternion<T>((T) 0.5 * e0 * s, c0 * q.x, c0 * q.y, c0 * q.z) +
        Quaternion<T>((T) 0.5 * e1 * s, c1 * q.x, c1 * q.y, c1 * q.z);
    }
}

template<class T> Quaternion<T> cos(Quaternion<T> q)
{
    if (q.isReal())
    {
        return Quaternion<T>((T) cos(q.w));
    }
    else
    {
        T l = (T) sqrt(q.x * q.x + q.y * q.y + q.z * q.z);
        T m = q.w;
        T s = (T) sin(m);
        T c = (T) cos(m);
        T il = 1 / l;
        T e0 = (T) exp(-l);
        T e1 = (T) exp(l);
        
        T c0 = (T)  0.5 * e0 * il * s;
        T c1 = (T) -0.5 * e1 * il * s;
        
        return Quaternion<T>((T) 0.5 * e0 * c, c0 * q.x, c0 * q.y, c0 * q.z) +
        Quaternion<T>((T) 0.5 * e1 * c, c1 * q.x, c1 * q.y, c1 * q.z);
    }
}

template<class T> Quaternion<T> sqrt(Quaternion<T> q)
{
    // In general, the square root of a quaternion has two values, one
    // of which is the negative of the other.  However, any negative purely
    // real quaternion has an infinite number of square roots.
    // This function returns the positive root for positive reals and
    // the root on the positive i axis for negative reals.
    if (q.isReal())
    {
        if (q.w >= 0)
            return Quaternion<T>((T) sqrt(q.w), 0, 0, 0);
        else
            return Quaternion<T>(0, (T) sqrt(-q.w), 0, 0);
    }
    else
    {
        T b = (T) sqrt(q.x * q.x + q.y * q.y + q.z * q.z);
        T r = (T) sqrt(q.w * q.w + b * b);
        if (q.w >= 0)
        {
            T m = (T) sqrt((T) 0.5 * (r + q.w));
            T l = b / (2 * m);
            T t = l / b;
            return Quaternion<T>(m, q.x * t, q.y * t, q.z * t);
        }
        else
        {
            T l = (T) sqrt((T) 0.5 * (r - q.w));
            T m = b / (2 * l);
            T t = l / b;
            return Quaternion<T>(m, q.x * t, q.y * t, q.z * t);
        }
    }
}

template<class T> T real(Quaternion<T> q)
{
    return q.w;
}

template<class T> Vector3<T> imag(Quaternion<T> q)
{
    return Vector3<T>(q.x, q.y, q.z);
}


// Quaternion methods

template<class T> bool Quaternion<T>::isReal() const
{
    return (x == 0 && y == 0 && z == 0);
}

template<class T> bool Quaternion<T>::isPure() const
{
    return w == 0;
}

template<class T> T Quaternion<T>::normalize()
{
    T s = (T) sqrt(w * w + x * x + y * y + z * z);
    T invs = (T) 1 / (T) s;
    x *= invs;
    y *= invs;
    z *= invs;
    w *= invs;
    
    return s;
}

// Set to the unit quaternion representing an axis angle rotation.  Assume
// that axis is a unit vector
template<class T> void Quaternion<T>::setAxisAngle(Vector3<T> axis, T angle)
{
    T s, c;
    
    Math<T>::sincos(angle * (T) 0.5, s, c);
    x = s * axis.x;
    y = s * axis.y;
    z = s * axis.z;
    w = c;
}


// Assuming that this a unit quaternion, return the in axis/angle form the
// orientation which it represents.
template<class T> void Quaternion<T>::getAxisAngle(Vector3<T>& axis,
                                                   T& angle) const
{
    // The quaternion has the form:
    // w = cos(angle/2), (x y z) = sin(angle/2)*axis
    
    T magSquared = x * x + y * y + z * z;
    if (magSquared > (T) 1e-10)
    {
        T s =  (T) 1 / (T) sqrt(magSquared);
        axis.x = x * s;
        axis.y = y * s;
        axis.z = z * s;
        if (w <= -1 || w >= 1)
            angle = 0;
        else
            angle = (T) acos(w) * 2;
    }
    else
    {
        // The angle is zero, so we pick an arbitrary unit axis
        axis.x = 1;
        axis.y = 0;
        axis.z = 0;
        angle = 0;
    }
}


// Convert this (assumed to be normalized) quaternion to a rotation matrix
template<class T> Matrix4<T> Quaternion<T>::toMatrix4() const
{
    T wx = w * x * 2;
    T wy = w * y * 2;
    T wz = w * z * 2;
    T xx = x * x * 2;
    T xy = x * y * 2;
    T xz = x * z * 2;
    T yy = y * y * 2;
    T yz = y * z * 2;
    T zz = z * z * 2;
    
    return Matrix4<T>(Vector4<T>(1 - yy - zz, xy - wz, xz + wy, 0),
                      Vector4<T>(xy + wz, 1 - xx - zz, yz - wx, 0),
                      Vector4<T>(xz - wy, yz + wx, 1 - xx - yy, 0),
                      Vector4<T>(0, 0, 0, 1));
}


// Convert this (assumed to be normalized) quaternion to a rotation matrix
template<class T> Matrix3<T> Quaternion<T>::toMatrix3() const
{
    T wx = w * x * 2;
    T wy = w * y * 2;
    T wz = w * z * 2;
    T xx = x * x * 2;
    T xy = x * y * 2;
    T xz = x * z * 2;
    T yy = y * y * 2;
    T yz = y * z * 2;
    T zz = z * z * 2;
    
    return Matrix3<T>(Vector3<T>(1 - yy - zz, xy - wz, xz + wy),
                      Vector3<T>(xy + wz, 1 - xx - zz, yz - wx),
                      Vector3<T>(xz - wy, yz + wx, 1 - xx - yy));
}


template<class T> T dot(Quaternion<T> a, Quaternion<T> b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w;
}


template<class T> Quaternion<T> Quaternion<T>::slerp(Quaternion<T> q0,
                                                     Quaternion<T> q1,
                                                     T t)
{
    T c = dot(q0, q1);
    T angle = (T) acos(c);
    
    if (abs(angle) < (T) 1.0e-5)
        return q0;
    
    T s = (T) sin(angle);
    T is = (T) 1.0 / s;
    
    return q0 * ((T) sin((1 - t) * angle) * is) +
    q1 * ((T) sin(t * angle) * is);
}


// Assuming that this is a unit quaternion representing an orientation,
// apply a rotation of angle radians about the specfied axis
template<class T> void Quaternion<T>::rotate(Vector3<T> axis, T angle)
{
    Quaternion q;
    q.setAxisAngle(axis, angle);
    *this = q * *this;
}


// Assuming that this is a unit quaternion representing an orientation,
// apply a rotation of angle radians about the x-axis
template<class T> void Quaternion<T>::xrotate(T angle)
{
    T s, c;
    
    Math<T>::sincos(angle * (T) 0.5, s, c);
    *this = Quaternion<T>(c, s, 0, 0) * *this;
}

// Assuming that this is a unit quaternion representing an orientation,
// apply a rotation of angle radians about the y-axis
template<class T> void Quaternion<T>::yrotate(T angle)
{
    T s, c;
    
    Math<T>::sincos(angle * (T) 0.5, s, c);
    *this = Quaternion<T>(c, 0, s, 0) * *this;
}

// Assuming that this is a unit quaternion representing an orientation,
// apply a rotation of angle radians about the z-axis
template<class T> void Quaternion<T>::zrotate(T angle)
{
    T s, c;
    
    Math<T>::sincos(angle * (T) 0.5, s, c);
    *this = Quaternion<T>(c, 0, 0, s) * *this;
}


#endif // _MATHLIB_H_
